# Create self signed certificates the easy way!

Working with the `openssl` CLI can be intimidating. Options are hard to remember.
So I've modified these scripts (from [BenMorel/dev-certificates](https://github.com/BenMorel/dev-certificates)) and instructions to make my life, and yours, easier!

## Download

Right click below, *Save Link As...*:

- [create-ca.sh](https://raw.githubusercontent.com/pimmerks/self-signed-certificates/main/create-ca.sh)
- [create-certificate.sh](https://raw.githubusercontent.com/pimmerks/self-signed-certificates/main/create-certificate.sh)

## Generate your own Certificate Authority

The *Certificate Authority* is what will make your browser trust the certificates that you'll generate for your local domains. Your browser is bundled with a list of Certificate Autorities that it trusts by default, but because you'll be signing your certificates yourself, you need to instruct it to trust your own certificates.

Just run:

```
create-ca.sh 
```

You only need to perform this step **once**.

## Generate a certificate for your domain

To generate a certificate for `example.dev` and its subdomains, run:

```
create-certificate.sh example.dev
```

You can now install the `.key` and `.crt` files in your web server, such as Apache or Nginx.

Repeat this step if you need certificates for other domain names.

## Import the CA in your browser

## That's it!

If you need to create certificates for other domains, just run `create-certificate.sh` again.
**No need to create or import the CA again!**

Enjoy! 👋

## Credits

These scripts have been modified from [BenMorel/dev-certificates](https://github.com/BenMorel/dev-certificates).

These scripts have been created from the steps highlighted in [this StackOverflow answer](https://stackoverflow.com/a/60516812/759866) by [@entrity](https://github.com/entrity).
