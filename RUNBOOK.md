Deploy infrastructure
`terraform apply`

Set up `kubectl`
`aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_id)`

Install Consul
`consul-k8s install -config-file=consul/values.yaml`

Deploy Web and API services
`kubectl apply --filename k8s-services/web.yaml`
`kubectl apply --filename k8s-services/api-success.yaml`

Deploy Consul API gateway and route it towards Web
`kubectl apply --filename api-gw/consul-api-gateway.yaml`
`kubectl apply --filename api-gw/ingress-web.yaml`

Access the Consul-UI
`kubectl port-forward -n consul service/consul-ui 8080:443 > /dev/null 2>&1 &`
Token:
`export CONSUL_HTTP_TOKEN=$(kubectl --namespace consul get secrets consul-bootstrap-acl-token --template='{{.data.token | base64decode}}') && echo $CONSUL_HTTP_TOKEN`
Open [Consul-UI](https://localhost:8080/ui/) and 

Access the Web service
`kubectl --namespace consul get services api-gateway -o jsonpath='{ .status.loadBalancer.ingress[].hostname }'`
Open Web, refresh a few times, observe the Upstream destination alternate between `api-v1` and `api-v2`.
Observe the Consul UI traffic metrics for `web` <-> `api`.

Simulate upstream HTTP 5xx errors for api-v2
`kubectl apply --filename k8s-services/api-fail.yaml`

Refresh the Web page a few times, observe that `api-v2` fails twice as upstream and then no longer appears.
Observe the [Consul-UI](https://localhost:8080/ui/dc1/services/web/topology) traffic metrics for `web` <-> `api` show errors.

Observe the Prometheus tripping of Envoy outlier detection for url
`kubectl port-forward -n consul service/prometheus-server 9090:80 > /dev/null 2>&1 &`
`http://localhost:9090/graph?g0.expr=envoy_cluster_outlier_detection_ejections_active&g0.tab=0&g0.stacked=0&g0.range_input=15m`

Destroy infrastructure
`terraform destroy`