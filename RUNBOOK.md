Deploy infrastructure
`terraform apply`

Set up `kubectl`
`aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)`

Access the Consul Token:
`export CONSUL_HTTP_TOKEN=$(kubectl --namespace consul get secrets consul-bootstrap-acl-token --template='{{.data.token | base64decode}}') && echo $CONSUL_HTTP_TOKEN`

Open the Consul UI URL and log in using the token from the previous step:
`export CONSUL_UI=https://$(kubectl --namespace consul get services consul-ui -o jsonpath='{ .status.loadBalancer.ingress[].hostname }') && echo $CONSUL_UI`

Access the Web service
`kubectl --namespace consul get services api-gateway -o jsonpath='{ .status.loadBalancer.ingress[].hostname }'`
Observe the Consul UI traffic metrics for the `public-api` service.

Simulate upstream HTTP 5xx errors for api-v2
`kubectl apply --filename k8s-services/failing-service-public-api.yaml`

Observe the Consul-UI traffic metrics for `public-api` show errors.
`echo $CONSUL_UI/ui/dc1/services/web/topology`

Apply circuit-breaking parameters for the `public-api` service.
`kubectl apply --filename k8s-services/servicedefaults-public-api.yaml`

Then redeploy the failing `public-api` services and their service mesh proxies.
`kubectl rollout restart deployment/public-api-v2`
`kubectl rollout restart deployment/public-api-v3`

-- At this point we have trouble with traffic-generator pod dying.

Observe the Consul-UI traffic metrics for `public-api` show errors trigger and then stop as non-functioning `public-api` service instances are ejected from the upstream destination pool.
`echo $CONSUL_UI/ui/dc1/services/web/topology`

Observe the Prometheus tripping of Envoy outlier detection for url
`kubectl port-forward -n consul service/prometheus-server 9090:80 > /dev/null 2>&1 &`
`http://localhost:9090/graph?g0.expr=envoy_cluster_outlier_detection_ejections_active&g0.tab=0&g0.stacked=0&g0.range_input=15m`

Destroy infrastructure
`terraform destroy`