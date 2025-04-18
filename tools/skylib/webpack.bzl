load("@aspect_rules_webpack//webpack:defs.bzl", _webpack_bundle = "webpack_bundle", _webpack_devserver = "webpack_devserver")

def webpack(
        name,
        srcs,
        **kwargs):
    """ Defines a `webpack_bundle` target.

    This macro is a wrapper around the `webpack_bundle` rule from `@aspect_rules_webpack//webpack:defs.bzl`.
    Alongside the `webpack_bundle` target, it also creates a [webpack_devserver](https://github.com/aspect-build/rules_webpack/blob/main/docs/rules.md#webpack_devserver) target if `include_webpack_serve` is set to `True`.

    To start your webpack dev server, inside your project, run the following command:
    ```
    bazel run :{name}.serve
    ```

    Args:
        name: The name of the target.
        srcs: The source files needed.
        **kwargs: Additional keyword arguments. See [webpack_bundle](https://github.com/aspect-build/rules_webpack/blob/main/docs/rules.md#webpack_bundle).
    """

    include_webpack_serve = kwargs.pop("include_webpack_serve", False)
    entry_point = kwargs.pop("entry_point", "dist/index.js")
    webpack_config = kwargs.pop("webpack_config", "webpack.config.cjs")
    data = kwargs.pop("data", [])

    _webpack_bundle(
        name = name,
        srcs = srcs,
        chdir = native.package_name(),
        entry_point = entry_point,
        node_modules = ":node_modules",
        output_dir = False,
        tags = ["webpack"],
        webpack_config = webpack_config,
        deps = [
            ":node_modules/webpack",
            ":node_modules/webpack-cli",
            ":node_modules/webpack-dev-server",
        ],
        **kwargs
    )

    if include_webpack_serve:
        _webpack_devserver(
            name = "{}.serve".format(name),
            chdir = native.package_name(),
            data = [
                ":{}".format(name),
                ":node_modules/webpack",
                ":node_modules/webpack-cli",
                ":node_modules/webpack-dev-server",
            ] + srcs + data,
            grant_sandbox_write_permissions = True,
            log_level = "debug",  # ["fatal", "error", "warn", "info", "debug"]
            node_modules = ":node_modules",
            tags = ["webpack_serve"],
            webpack_config = "webpack.config.cjs",
            **kwargs
        )
