# Docker compose for INDIGO IAM

This folder can be used to play with the IAM web interface and `iam-test-client` (a demo Web application which allows you, among other things, to get an access token).

## Run the compose

Create the required missing files (the variables may remain blank)

* `env-files/iam-dev.env` with the following content
  ```bash
  IAM_DEV_CLIENT_ID=
  IAM_DEV_CLIENT_SECRET=
  ```
* `env-files/orcid.env` with the following content
  ```bash
  ORCID_CLIENT_ID=
  ORCID_CLIENT_SECRET=
  ```

Build the trustanchor

```bash
docker compose build --no-cache trust
```

Run the services with

```bash
docker compose up -d
```

The docker-compose contains several services:

* `trust`: docker image for the _igi-test-ca_ CA certificate issuing server/user certificates, usually mounted in the `/etc/grid-security/certificates` path of the other services. The container populates a `/certs` volume containing server X.509 certificates
* `iam-be`: is the main service, also known as `iam-login-service`. The INDIGO IAM base URL is https://iam.test.example
* `demo`: is an example of a client application (also known as `iam-test-client`), where a login button redirects to `iam-be` to start an authorization code flow. URL of this service is https://iam.test.example/iam-test-client
* `iam`: is an `nginx` image used for TLS termination and reverse proxy
* `db`: is a mysql database used by INDIGO IAM. A dump of the database with test users plus a _test0_ certificate linked to an account may be enabled.
  
To resolve the hostname of the service, add a line in your `/etc/hosts` file with

```
127.0.0.1	iam.test.example
```

## DB

The IAM database is populated with test users/certificates, in particular

* admin user: login with admin/password
* test user: login with test/password (the test0 certificate is linked to this account).

To have a full production instance (with only the Admin user in the db) remove the injection of the db dump in the db service container.

## IAM

Available at https://iam.test.example/.

The IAM database is populated with test users/certificates. 
To have a full production instance (with only the Admin user in the db) remove the injection of the db dump in the db service container. The Admin user will be the only one available during the first login phase.

To switch between different IAM versions, change the `IAM_IMAGE_TAG` variable located in the `.env` file with the desired version.

### Browsing IAM

In order to trust the server certificate, you must to provide the browser with the CA.

You can find it in

```bash
docker compose exec clients bash
cat /etc/grid-security/certificates/igi_test_ca.pem     # Copy and paste this
```

otherwise, just _Accept risk and continue_.

## iam-test-client (demo application)

Available at https://iam.test.example/iam-test-client.

It is a demo application to showcase what happens during an authorization code flow request.

After a login with IAM, `iam-test-client` shows

* an encoded access token (obtained with the authorization code flow)
* the decoded access token claims
* the introspection endpoint response of IAM (which basically states if the token is valid)
* an encoded id token (obtained when requesting the `openid` scope)
* the decoded id token claims
* the userinfo endpoint response of IAM (which basically returns information about the authenticated user)
* an encoded refresh token (obtained when requesting the `offline_access` scope).
