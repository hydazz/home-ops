# Maddy DNS Records

Replace `example.com` with the actual domain and import as needed.

```
mail.example.com.                 1   IN  CNAME  mail.hyde.services. ; cf_tags=cf-proxied:false
example.com.                      1   IN  MX     10 mail.example.com.
example.com.                      1   IN  TXT    "v=spf1 mx a:mail.example.com ~all"
_dmarc.example.com.               1   IN  TXT    "v=DMARC1; p=quarantine; ruf=mailto:postmaster@example.com"
default._domainkey.example.com.   1   IN  TXT    "v=DKIM1; k=rsa; p=<DKIM_KEY>"
```
