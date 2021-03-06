#!/usr/bin/env bash
# Copyright 2016 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

TESTINFRA_ROOT=$(git rev-parse --show-toplevel)
# https://github.com/kubernetes/test-infra/issues/5699#issuecomment-348350792
cd ${TESTINFRA_ROOT}
TMP_GOPATH=$(mktemp -d)

"${TESTINFRA_ROOT}/hack/go_install_from_commit.sh" \
  github.com/kubernetes/repo-infra/kazel \
  2a736b4fba317cf3038e3cbd06899b544b875fae \
  "${TMP_GOPATH}"

"${TESTINFRA_ROOT}/hack/go_install_from_commit.sh" \
  github.com/bazelbuild/bazel-gazelle/cmd/gazelle \
  578e73e57d6a4054ef933db1553405c9284322c7 \
  "${TMP_GOPATH}"

touch "${TESTINFRA_ROOT}/vendor/BUILD.bazel"

"${TMP_GOPATH}/bin/gazelle" fix \
  -external=vendored \
  -mode=fix \
  -repo_root="${TESTINFRA_ROOT}"

"${TMP_GOPATH}/bin/kazel" -root="${TESTINFRA_ROOT}"
