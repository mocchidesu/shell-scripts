Skip to content
Enterprise
Search or jump to…

Pull requests
Issues
Explore
@h0m00i5Sign out
Commit to Proper Secret Storage - Protect Our Customers By Protecting Our Keys. Visit https://appsec.walmart.com/secrets/ to learn how

47
215platform/istio-deploy
 Code Issues 1 Pull requests 2 Projects 0 Wiki Insights Settings
istio-deploy/scripts/test.sh
33743df on Jun 5
@c0l0232 c0l0232 Update the rbac setting which required on prod env.
   
Executable File  79 lines (66 sloc)  1.78 KB
#!/usr/bin/env bash

DARKGRAY='\033[1;30m'
RED='\033[0;31m'
LIGHTRED='\033[1;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
LIGHTPURPLE='\033[1;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'

SET='\033[0m'

PASSED=0
FAILED=0

pass() {
  echo -e "${GREEN}PASS${SET}: $1"
  ((PASSED++))
}

fail() {
  echo -e "${RED}FAIL${SET}: $1"
  ((FAILED++))
}

if [ $# -lt 1 ]; then
  ctx=$(kubectl config current-context)
  echo
  echo "Usage: $0 cluster_id"
  echo " e.g.: $0 eus2-stage-afscale1"
  echo "To use current context, try"
  echo "$0 $ctx"
  echo "use current context Y/n? [ENTER]"
  read use_current

  if [[ "$use_current" =~ n|N ]]; then
    echo
    exit 0
  fi
fi

cluster_id=${1:-$ctx}; echo "cluster_id=$cluster_id"
CLUSTER_HOST="test.${cluster_id}.cluster.k8s.us.walmart.net"; echo "cluster_host=$CLUSTER_HOST"
resolve=$(nslookup ${CLUSTER_HOST}|grep Address|tail -1|awk '{print $2}'); echo "resolve=$resolve"

kubecmd="kubectl --context $cluster_id"

assertion="ingressgateway proxy concurrency should equal to 4"
x=$($kubecmd get deployment -n istio-system istio-ingressgateway -o yaml |grep '\-\-concurrency' -A2|grep 4)
if [ -z "$x" ]; then
  fail "$assertion"
elif [[ ! $x =~ .*\"4\"$ ]]; then
  fail "$assertion"
else
  pass "$assertion"
fi

assertion="sds is enabled"
x=$($kubecmd get -n istio-system deployment istio-ingressgateway -o yaml |grep node-agent-k8s)
if [ -z "$x" ]; then
  fail "$assertion"
else
  pass "$assertion"
fi

assertion="istio idle timeout should equal to 2m"
x=$($kubecmd get -n istio-system deployment istio-ingressgateway -o yaml |grep IDLE_TIMEOUT -A1 |grep value:)
if [ -z "$x" ]; then
  fail "$assertion"
elif [[ ! $x =~ value:[[:space:]]*2m$ ]]; then
  fail "$assertion"
else
  pass "$assertion"
fi

printf "PASSED: %d FAILED: %d\n" $PASSED $FAILED
© 2019 GitHub, Inc.
Help
Support
API
Training
Blog
About
GitHub Enterprise Server 2.16.14
Press h to open a hovercard with more details.
