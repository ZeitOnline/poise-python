# coding: utf-8
#
# Copyright 2015-2017, Noah Kantrowitz
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

name "poise-python"
version "1.7.1"
description "A Chef cookbook for managing Python installations."
long_description "# Poise-Python Cookbook\n\n[![Build Status](https://img.shields.io/travis/poise/poise-python.svg)](https://travis-ci.org/poise/poise-python)\n[![Gem Version](https://img.shields.io/gem/v/poise-python.svg)](https://rubygems.org/gems/poise-python)\n[![Cookbook Version](https://img.shields.io/cookbook/v/poise-python.svg)](https://supermarket.chef.io/cookbooks/poise-python)\n[![Coverage](https://img.shields.io/codecov/c/github/poise/poise-python.svg)](https://codecov.io/github/poise/poise-python)\n[![Gemnasium](https://img.shields.io/gemnasium/poise/poise-python.svg)](https://gemnasium.com/poise/poise-python)\n[![License](https://img.shields.io/badge/license-Apache_2-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)\n\nA [Chef](https://www.chef.io/) cookbook to provide a unified interface for\ninstalling Python, managing Python packages, and creating virtualenvs.\n\n## Quick Start\n\nTo install the latest available version of Python 2 and then use it to create\na virtualenv and install some packages:\n\n```ruby\npython_runtime '2'\n\npython_virtualenv '/opt/myapp/.env'\n\npython_package 'Django' do\n  version '1.8'\nend\n\npip_requirements '/opt/myapp/requirements.txt'\n```\n\n## Installing a Package From a URI\n\nWhile using `python_package 'git+https://github.com/example/mypackage.git'` will\nsometimes work, this approach is not recommended. Unfortunately pip's support\nfor installing directly from URI sources is limited and cannot support the API\nused for the `python_package` resource. You can run the install either directly\nfrom the URI or through an intermediary `git` resource:\n\n```ruby\n# Will re-install on every converge unless you add a not_if/only_if.\npython_execute '-m pip install git+https://github.com/example/mypackage.git'\n\n# Will only re-install when the git repository updates.\npython_execute 'install mypackage' do\n  action :nothing\n  command '-m pip install .'\n  cwd '/opt/mypackage'\nend\ngit '/opt/mypackage' do\n  repository 'https://github.com/example/mypackage.git'\n  notifies :run, 'python_execute[install mypackage]', :immediately\nend\n```\n\n## Supported Python Versions\n\nThis cookbook can install at least Python 2.7, Python 3, and PyPy on all\nsupported platforms (Debian, Ubuntu, RHEL, CentOS, Fedora).\n\n### Windows Support\n\nThe latest version of `poise-python` includes basic support for managing Python\non Windows. This currently doesn't support Python 3.5, but everything should be\nworking. Consider this support tested but experimental at this time.\n\n## Requirements\n\nChef 12.1 or newer is required.\n\n## Attributes\n\nAttributes are used to configure the default recipe.\n\n* `node['poise-python']['install_python2']` – Install a Python 2.x runtime. *(default: true)*\n* `node['poise-python']['install_python3']` – Install a Python 3.x runtime. *(default: false)*\n* `node['poise-python']['install_pypy']` – Install a PyPy runtime. *(default: false)*\n\n## Recipes\n\n### `default`\n\nThe default recipe installs Python 2, 3, and/or PyPy based on the node\nattributes. It is entirely optional and can be ignored in favor of direct use\nof the `python_runtime` resource.\n\n## Resources\n\n### `python_runtime`\n\nThe `python_runtime` resource installs a Python interpreter.\n\n```ruby\npython_runtime '2'\n```\n\n#### Actions\n\n* `:install` – Install the Python interpreter. *(default)*\n* `:uninstall` – Uninstall the Python interpreter.\n\n#### Properties\n\n* `version` – Version of Python to install. If a partial version is given, use the\n  latest available version matching that prefix. *(name property)*\n* `get_pip_url` – URL to download the `get-pip.py` bootstrap script from.\n  *(default: https://bootstrap.pypa.io/get-pip.py)*\n* `pip_version` – Version of pip to install. If set to `true`, use the latest.\n  If set to `false`, do not install pip. For backward compatibility, can also be\n  set to a URL instead of `get_pip_url`. *(default: true)*\n* `setuptools_version` – Version of Setuptools to install. If set to `true`, use\n  the latest. If set to `false`, do not install Setuptools. *(default: true)*\n* `virtualenv_version` – Version of virtualenv to install. If set to `true`,\n  use the latest. If set to `false`, do not install virtualenv. Will never be\n  installed if the `venv` module is already available, such as on Python 3.\n  *(default: true)*\n* `wheel_version` – Version of wheel to install. If set to `true`, use the\n  latest. If set to `false`, do not install wheel.\n\n#### Provider Options\n\nThe `poise-python` library offers an additional way to pass configuration\ninformation to the final provider called \"options\". Options are key/value pairs\nthat are passed down to the `python_runtime` provider and can be used to control how it\ninstalls Python. These can be set in the `python_runtime`\nresource using the `options` method, in node attributes or via the\n`python_runtime_options` resource. The options from all sources are merged\ntogether in to a single hash.\n\nWhen setting options in the resource you can either set them for all providers:\n\n```ruby\npython_runtime 'myapp' do\n  version '2.7'\n  options pip_version: false\nend\n```\n\nor for a single provider:\n\n```ruby\npython_runtime 'myapp' do\n  version '2.7'\n  options :system, dev_package: false\nend\n```\n\nSetting via node attributes is generally how an end-user or application cookbook\nwill set options to customize installations in the library cookbooks they are using.\nYou can set options for all installations or for a single runtime:\n\n```ruby\n# Global, for all installations.\noverride['poise-python']['options']['pip_version'] = false\n# Single installation.\noverride['poise-python']['myapp']['version'] = 'pypy'\n```\n\nThe `python_runtime_options` resource is also available to set node attributes\nfor a specific installation in a DSL-friendly way:\n\n```ruby\npython_runtime_options 'myapp' do\n  version '3'\nend\n```\n\nUnlike resource attributes, provider options can be different for each provider.\nNot all providers support the same options so make sure to the check the\ndocumentation for each provider to see what options the use.\n\n### `python_runtime_options`\n\nThe `python_runtime_options` resource allows setting provider options in a\nDSL-friendly way. See [the Provider Options](#provider-options) section for more\ninformation about provider options overall.\n\n```ruby\npython_runtime_options 'myapp' do\n  version '3'\nend\n```\n\n#### Actions\n\n* `:run` – Apply the provider options. *(default)*\n\n#### Properties\n\n* `resource` – Name of the `python_runtime` resource. *(name property)*\n* `for_provider` – Provider to set options for.\n\nAll other attribute keys will be used as options data.\n\n### `python_execute`\n\nThe `python_execute` resource executes a Python script using the configured runtime.\n\n```ruby\npython_execute 'myapp.py' do\n  user 'myuser'\nend\n```\n\nThis uses the built-in `execute` resource and supports all the same properties.\n\n#### Actions\n\n* `:run` – Execute the script. *(default)*\n\n#### Properties\n\n* `command` – Script and arguments to run. Must not include the `python`. *(name attribute)*\n* `python` – Name of the `python_runtime` resource to use. If not specified, the\n  most recently declared `python_runtime` will be used. Can also be set to the\n  full path to a `python` binary.\n* `virtualenv` – Name of the `python_virtualenv` resource to use. This is\n  mutually exclusive with the `python` property.\n\nFor other properties see the [Chef documentation](https://docs.chef.io/resource_execute.html#attributes).\n\n### `python_package`\n\nThe `python_package` resource installs Python packages using\n[pip](https://pip.pypa.io/).\n\n```ruby\npython_package 'Django' do\n  version '1.8'\nend\n```\n\nThis uses the built-in `package` resource and supports the same actions and\nproperties. Multi-package installs are supported using the standard syntax.\n\n#### Actions\n\n* `:install` – Install the package. *(default)*\n* `:upgrade` – Install using the `--upgrade` flag.\n* `:remove` – Uninstall the package.\n\nThe `:purge` and `:reconfigure` actions are not supported.\n\n#### Properties\n\n* `group` – System group to install the package.\n* `package_name` – Package or packages to install. *(name property)*\n* `version` – Version or versions to install.\n* `python` – Name of the `python_runtime` resource to use. If not specified, the\n  most recently declared `python_runtime` will be used. Can also be set to the\n  full path to a `python` binary.\n* `user` – System user to install the package.\n* `virtualenv` – Name of the `python_virtualenv` resource to use. This is\n  mutually exclusive with the `python` property.\n* `options` – Options to pass to `pip`.\n* `install_options` – Options to pass to `pip install` (and similar commands).\n* `list_options` – Options to pass to `pip list` (and similar commands).\n\nFor other properties see the [Chef documentation](https://docs.chef.io/resource_package.html#attributes).\nThe `response_file`, `response_file_variables`, and `source` properties are not\nsupported.\n\n### `python_virtualenv`\n\nThe `python_virtualenv` resource creates Python virtual environments.\n\n```ruby\npython_virtualenv '/opt/myapp'\n```\n\nThis will use the `venv` module if available, or `virtualenv` otherwise.\n\n#### Actions\n\n* `:create` – Create the virtual environment. *(default)*\n* `:delete` – Delete the virtual environment.\n\n#### Properties\n\n* `group` – System group to create the virtualenv.\n* `path` – Path to create the environment at. *(name property)*\n* `pip_version` – Version of pip to install. If set to `true`, use the latest.\n  If set to `false`, do not install pip. Can also be set to a URL to a copy of\n  the `get-pip.py` script. *(default: true)*\n* `python` – Name of the `python_runtime` resource to use. If not specified, the\n  most recently declared `python_runtime` will be used. Can also be set to the\n  full path to a `python` binary.\n* `setuptools_version` – Version of Setuptools to install. If set to `true`, use\n  the latest. If set to `false`, do not install Setuptools. *(default: true)*\n* `system_site_packages` – Enable or disable visibilty of system packages in\n  the environment. *(default: false)*\n* `user` – System user to create the virtualenv.\n* `wheel_version` – Version of wheel to install. If set to `true`, use the\n  latest. If set to `false`, do not install wheel.\n\n### `pip_requirements`\n\nThe `pip_requirements` resource installs packages based on a `requirements.txt`\nfile.\n\n```ruby\npip_requirements '/opt/myapp/requirements.txt'\n```\n\nThe underlying `pip install` command will run on every converge, but\nnotifications will only be triggered if a package is actually installed.\n\n#### Actions\n\n* `:install` – Install the requirements. *(default)*\n* `:upgrade` – Install using the `--upgrade` flag.\n\n#### Properties\n\n* `path` – Path to the requirements file, or a folder containing the\n  requirements file. *(name property)*\n* `cwd` – Directory to run `pip` from. *(default: directory containing the\n  `requirements.txt`)*\n* `group` – System group to install the packages.\n* `options` – Command line options for use with `pip install`.\n* `python` – Name of the `python_runtime` resource to use. If not specified, the\n  most recently declared `python_runtime` will be used. Can also be set to the\n  full path to a `python` binary.\n* `user` – System user to install the packages.\n* `virtualenv` – Name of the `python_virtualenv` resource to use. This is\n  mutually exclusive with the `python` property.\n\n## Python Providers\n\n### Common Options\n\nThese provider options are supported by all providers.\n\n* `pip_version` – Override the pip version.\n* `setuptools_version` – Override the Setuptools version.\n* `version` – Override the Python version.\n* `virtualenv_version` – Override the virtualenv version.\n* `wheel_version` – Override the wheel version.\n\n### `system`\n\nThe `system` provider installs Python using system packages. This is currently\nonly tested on platforms using `apt-get` and `yum` (Debian, Ubuntu, RHEL, CentOS\nAmazon Linux, and Fedora) and is a default provider on those platforms. It may\nwork on other platforms but is untested.\n\n```ruby\npython_runtime 'myapp' do\n  provider :system\n  version '2.7'\nend\n```\n\n#### Options\n\n* `dev_package` – Install the package with the headers and other development\n  files. Can be set to a string to select the dev package specifically.\n  *(default: true)*\n* `package_name` – Override auto-detection of the package name.\n* `package_upgrade` – Install using action `:upgrade`. *(default: false)*\n* `package_version` – Override auto-detection of the package version.\n\n### `scl`\n\nThe `scl` provider installs Python using the [Software Collections](https://www.softwarecollections.org/)\npackages. This is only available on RHEL, CentOS, and Fedora. SCL offers more\nrecent versions of Python than the system packages for the most part. If an SCL\npackage exists for the requested version, it will be used in preference to the\n`system` provider.\n\n```ruby\npython_runtime 'myapp' do\n  provider :scl\n  version '3.4'\nend\n```\n\n### `portable_pypy`\n\nThe `portable_pypy` provider installs Python using the [Portable PyPy](https://github.com/squeaky-pl/portable-pypy)\npackages. These are only available for Linux, but should work on any Linux OS.\n\n```ruby\npython_runtime 'myapp' do\n  provider :portable_pypy\n  version 'pypy'\nend\n```\n\n### `portable_pypy3`\n\nThe `portable_pypy3` provider installs Python 3 using the [Portable PyPy](https://github.com/squeaky-pl/portable-pypy)\npackages. These are only available for Linux, but should work on any Linux OS.\n\n```ruby\npython_runtime 'myapp' do\n  provider :portable_pypy3\n  version 'pypy3'\nend\n```\n\n#### Options\n\n* `folder` – Folder to install PyPy in. *(default: /opt/<package name>)*\n* `url` – URL to download the package from. *(default: automatic)*\n\n### `deadsnakes`\n\n*Coming soon!*\n\n### `python-build`\n\n*Coming soon!*\n\n## Upgrading from the `python` Cookbook\n\nThe older `python` cookbook is not directly compatible with this one, but the\nbroad strokes overlap well. The `python::default` recipe is roughly equivalent\nto the `poise-python::default` recipe. The `python::pip` and `python::virtualenv`\nrecipes are no longer needed as installing those things is now part of the\n`python_runtime` resource. The `python::package` recipe corresponds with the\n`system` provider for the `python_runtime` resource, and can generally be\nreplaced with `poise-python::default`. At this time there is no provider to\ninstall from source so there is no replacement for the `python::source` recipe,\nhowever this is planned for the future via a `python-build` provider.\n\nThe `python_pip` resource can be replaced with `python_package`, though the\n`environment` property has been removed. The `python_virtualenv` resource can remain\nunchanged except for the `interpreter` property now being `python` and the\n`options` property has been removed.\n\n## Sponsors\n\nDevelopment sponsored by [Bloomberg](http://www.bloomberg.com/company/technology/).\n\nThe Poise test server infrastructure is sponsored by [Rackspace](https://rackspace.com/).\n\n## License\n\nCopyright 2015-2017, Noah Kantrowitz\n\nLicensed under the Apache License, Version 2.0 (the \"License\");\nyou may not use this file except in compliance with the License.\nYou may obtain a copy of the License at\n\nhttp://www.apache.org/licenses/LICENSE-2.0\n\nUnless required by applicable law or agreed to in writing, software\ndistributed under the License is distributed on an \"AS IS\" BASIS,\nWITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\nSee the License for the specific language governing permissions and\nlimitations under the License.\n"
maintainer "Noah Kantrowitz"
maintainer_email "noah@coderanger.net"
source_url "https://github.com/poise/poise-python" if defined?(source_url)
issues_url "https://github.com/poise/poise-python/issues" if defined?(issues_url)
license "Apache-2.0"
depends "poise", "~> 2.7"
depends "poise-languages", "~> 2.0"
chef_version ">= 12.16", "< 15" if defined?(chef_version)
supports "ubuntu"
supports "debian"
supports "redhat"
supports "centos"
supports "fedora"
supports "amazon"
supports "windows"
