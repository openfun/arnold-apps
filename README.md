# Arnold applications

This repository contains sources of officially maintained Arnold applications,
_a.k.a._ trays.

## Requirements

In order to work on this project and run a local development cluster, the
following dependencies should be installed first:

- `curl`
- `k3d`: https://k3d.io
- `kubectl`: https://kubernetes.io/fr/docs/tasks/tools/install-kubectl/

## Quick start for developers

Set your working environment:

```
$ make bootstrap && source .env
```

Setup a new Arnold project:

```
$ arnold -c hd-inc -e development setup
```

> Note the `arnold` command is an alias for `bin/arnold -v
> ${PWD}/apps:/app/apps` to override default bundled applications with
> applications from this project.

Edit the `group_vars/customer/hd-inc/main.yml` file to update variables values
for this working project.

Let say you want to create a new `foo` application. You should now create the
expected application tree in the `apps` directory:

```
apps
└── foo
    ├── templates
    │   ├── services
    │   │   └── app
    │   │       ├── configs
    │   │       ├── dc.yml.j2
    │   │       ├── route.yml.j2
    │   │       ├── secret.yml.j2
    │   │       └── svc.yml.j2
    │   └── volumes
    │       └── home.yml.j2
    ├── tray.yml
    └── vars
        ├── all
        │   └── main.yml
        ├── settings.yml
        └── vault
            └── main.yml.j2

9 directories, 9 files
```

You may now create expected application vaults _via_:

```
$ arnold -c hd-inc -e development -a foo create_app_vaults
```

You are now ready to start an OKD cluster:

```
$ make cluster
```

Once started, it's time to deploy and test our application:

```
$ arnold -c hd-inc -e development -a foo bootstrap
```

Yata!

> Note that you can stop the cluster using the `make stop` command.

## Contributing

Please, see the [CONTRIBUTING](CONTRIBUTING.md) file.

## Contributor Code of Conduct

Please note that this project is released with a [Contributor Code of
Conduct](http://contributor-covenant.org/). By participating in this project you
agree to abide by its terms. See [CODE_OF_CONDUCT](CODE_OF_CONDUCT.md) file.

## License

The code in this repository is licensed under the MIT license terms unless
otherwise noted.

Please see `LICENSE` for details.
