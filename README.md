# Learn Consul - Canary deployments with service splitters

This is a companion repo to the [Implement circuit breakers to improve service resilience](https://developer.hashicorp.com/consul/tutorials/resiliency/service-mesh-circuit-breaking), containing sample configuration to:

- Deploy an Elastic Kubernetes Service (EKS) cluster with Terraform
- Deploy Consul to EKS cluster
- Deploy example application HashiCups with redundant upstream microservices
- Configure a circuit breaker
- Trip the circuit breaker for simulating an outage by deactivating an upstream service deeper in the communication chain
- Observe the circuit breaker bring down the downstream services affected by the upstream service deactivation