Deploy infrastructure
`terraform apply`

Set up `kubectl`
`aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_id)`

Access the Consul Token:
`export CONSUL_HTTP_TOKEN=$(kubectl --namespace consul get secrets consul-bootstrap-acl-token --template='{{.data.token | base64decode}}') && echo $CONSUL_HTTP_TOKEN`

Open the Consul UI URL and log in using the token from the previous step:
`export CONSUL_UI=https://$(kubectl --namespace consul get services consul-ui -o jsonpath='{ .status.loadBalancer.ingress[].hostname }') && echo $CONSUL_UI`

Access the Web service
`kubectl --namespace consul get services api-gateway -o jsonpath='{ .status.loadBalancer.ingress[].hostname }'`
Open Web, refresh a few times, observe the Upstream destination alternate between `api-v1` and `api-v2`.
Observe the Consul UI traffic metrics for `web` <-> `api`.

Simulate upstream HTTP 5xx errors for api-v2
`kubectl apply --filename k8s-services/failing-service-api.yaml`

Refresh the Web page a few times, observe that `api-v2` fails twice as upstream and then no longer appears.
Observe the Consul-UI traffic metrics for `web` <-> `api` show errors.
`echo $CONSUL_UI/ui/dc1/services/web/topology`

Observe the Prometheus tripping of Envoy outlier detection for url
`kubectl port-forward -n consul service/prometheus-server 9090:80 > /dev/null 2>&1 &`
`http://localhost:9090/graph?g0.expr=envoy_cluster_outlier_detection_ejections_active&g0.tab=0&g0.stacked=0&g0.range_input=15m`

Destroy infrastructure
`terraform destroy`