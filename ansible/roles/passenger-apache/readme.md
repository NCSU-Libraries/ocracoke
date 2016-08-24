# passenger-apache role

For this to work right now something like the following needs to be run to create a self-signed certificate. All default values can be accepted. Still looking for option to accept all defaults. Replace "hostname".

```
sudo openssl req -x509 -nodes -batch -days 365 -newkey rsa:2048 -keyout /etc/pki/tls/certs/circa.lib.ncsu.edu.key -out /etc/pki/tls/certs/circa.lib.ncsu.edu.crt
```
