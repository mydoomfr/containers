# FreshRSS

This image exists because the upstream FreshRSS container is designed as a general-purpose image and still runs the main process as root by default. That is convenient for the upstream entrypoint because it can rewrite Apache/PHP configuration, install cron entries, and repair file permissions at container startup. This image makes a different, intentionally opinionated tradeoff: the container should be immutable at runtime and compatible with a hardened Kubernetes `securityContext`.

The image therefore bakes the runtime configuration during the build instead of mutating files at startup. Apache listens on `8080`, PHP limits are configured ahead of time, FreshRSS updates are disabled inside the application, and ownership is prepared for `nobody:nogroup` (`65534:65533`). The upstream permission repair script is removed because it requires root and does not fit a rootless runtime.

Feed refresh is also kept out of the web process. Instead of running cron inside the container, refresh should be handled by a sidecar or a Kubernetes `CronJob` using the same image and the same FreshRSS data volume.

The build still follows upstream FreshRSS logic where it matters: FreshRSS is installed from the upstream release archive, and the base is Alpine pinned by digest. This lets Renovate update both the FreshRSS version and the Alpine digest while keeping the hardening choices local to this image.

The container is designed for Kubernetes:

- runs as `nobody:nogroup` (`65534:65533`)
- supports `readOnlyRootFilesystem: true`
- requires no Linux capabilities
- writes only to mounted `data`, `extensions`, `/run/apache2`, and `/tmp`
- does not run cron inside the web process

## Kubernetes Example

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: freshrss
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: freshrss
  template:
    metadata:
      labels:
        app.kubernetes.io/name: freshrss
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 65534
        runAsGroup: 65533
        fsGroup: 65533
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: freshrss-web
          image: ghcr.io/mydoomfr/freshrss:1.29.1
          ports:
            - name: http
              containerPort: 8080
          securityContext:
            readOnlyRootFilesystem: true
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
          volumeMounts:
            - name: freshrss-data
              mountPath: /var/www/FreshRSS/data
            - name: freshrss-extensions
              mountPath: /var/www/FreshRSS/extensions
            - name: apache-run
              mountPath: /run/apache2
            - name: tmp
              mountPath: /tmp

        - name: freshrss-refresh
          image: ghcr.io/mydoomfr/freshrss:1.29.1
          command:
            - /bin/sh
            - -c
            - "while true; do php /var/www/FreshRSS/app/actualize_script.php; sleep 1200; done"
          securityContext:
            readOnlyRootFilesystem: true
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
          volumeMounts:
            - name: freshrss-data
              mountPath: /var/www/FreshRSS/data
            - name: freshrss-extensions
              mountPath: /var/www/FreshRSS/extensions
            - name: tmp
              mountPath: /tmp
      volumes:
        - name: freshrss-data
          persistentVolumeClaim:
            claimName: freshrss-data
        - name: freshrss-extensions
          persistentVolumeClaim:
            claimName: freshrss-extensions
        - name: apache-run
          emptyDir: {}
        - name: tmp
          emptyDir: {}
```

The sidecar refreshes feeds every 20 minutes. If you prefer not to keep a refresh sidecar running, use a Kubernetes `CronJob` with the same image and mounted volumes:

```yaml
command:
  - /bin/sh
  - -c
  - php /var/www/FreshRSS/app/actualize_script.php
```

The web container and the refresh container must share the same `data` volume.
