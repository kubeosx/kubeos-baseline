
## Getting started with jaeger

This is an all in one jaeger , which has inbult support for collector, suporting otel, zipkin formats, and jaeger UI.


image : jaegertracing/all-in-one:1.42.0

The service expose below posrt for services to use.

```yaml
  ports:
    - name: jaeger-collector-tchannel
      port: 14267
      protocol: TCP
      targetPort: 14267
    - name: jaeger-collector-http
      port: 14268
      protocol: TCP
      targetPort: 14268
    - name: jaeger-collector-zipkin
      port: 9411
      protocol: TCP
      targetPort: 9411
    - name: grpc-otlp
      port: 4317
      protocol: TCP
      targetPort: 4317
    - name: http-otlp
      port: 4318
      protocol: TCP
      targetPort: 4318
```