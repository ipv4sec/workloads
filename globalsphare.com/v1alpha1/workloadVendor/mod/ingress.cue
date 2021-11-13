import "mod/context"

parameter: {
  ingress?: {
    host: string
    path?: [...string]
  }
}
if parameter["traits"] != _|_ {
  if parameter["traits"]["globalsphare.com/v1alpha1/trait/ingress"] != _|_ {
    "ingress": "ingressgateway-http": {
      apiVersion: "networking.istio.io/v1alpha3"
      kind: "Gateway"
      metadata: {
        name: "\(context.namespace)-http"
        namespace: "island-system"
      }
      spec: {
        selector: istio: "ingressgateway"
        servers: [
          {
            port: {
              number: 80
              name: "http"
              protocol: "HTTP"
            }
            hosts: [
              parameter["traits"]["globalsphare.com/v1alpha1/trait/ingress"]["host"],
            ]
          },
        ]
      }
    }
    "ingress": "ingressgateway-https": {
      apiVersion: "networking.istio.io/v1alpha3"
      kind: "Gateway"
      metadata: {
        name: "\(context.namespace)-https"
        namespace: "island-system"
      }
      spec: {
        selector: istio: "ingressgateway"
        servers: [
          {
            port: {
              number: 443
              name: "https"
              protocol: "HTTPS"
            }
            tls: {
              mode: "SIMPLE"
              serverCertificate: "/etc/istio/ingressgateway-certs/tls.crt"
              privateKey: "/etc/istio/ingressgateway-certs/tls.key"
            }
            hosts: [
              parameter["traits"]["globalsphare.com/v1alpha1/trait/ingress"]["host"],
            ]
          },
        ]
      }
    }

    "ingress": "virtualservice-http": {
      apiVersion: "networking.istio.io/v1alpha3"
      kind: "VirtualService"
      metadata: {
        name: "\(context.appName)-http"
        namespace: context.namespace
      }
      spec: {
        hosts: ["*"]
        gateways: ["island-system/\(context.namespace)-http"]
        http: [
          {
            name: context.componentName
            if parameter["traits"]["globalsphare.com/v1alpha1/trait/ingress"]["http"] != _|_ {
              match: []
            }
            route: [{
              destination: {
                port: number: 80
                host: context.componentName
              },
              headers: {
                request: {
                  add: {
                    "X-Forwarded-Host": parameter["traits"]["globalsphare.com/v1alpha1/trait/ingress"]["host"]
                  }
                }
              }
            }]
          },
        ]
      }
    }

    "ingress": "virtualservice-https": {
      apiVersion: "networking.istio.io/v1alpha3"
      kind: "VirtualService"
      metadata: {
        name: "\(context.appName)-https"
        namespace: context.namespace
      }
      spec: {
        hosts: ["*"]
        gateways: ["island-system/\(context.namespace)-https"]
        http: [
          {
            match: []
            route: [
              {
                destination: {
                  host: context.componentName
                  port: {
                    number: 80
                  }
                },
                headers: {
                  request: {
                    add: {
                      "X-Forwarded-Host": parameter["traits"]["globalsphare.com/v1alpha1/trait/ingress"]["host"]
                    }
                  }
                }
              }
            ]
          }
        ]
      }
    }
  }
}