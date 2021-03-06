  $ . $TESTDIR/testing/harness/helpers.sh
  $ setup_test_env
  Restarting Test Environment
  $ cd client

Create a commit to test

  $ echo initial > foo
  $ hg commit -Am 'Bug 1 - some stuff'
  adding foo
  $ hg push
  pushing to $HGWEB_URL/test-repo
  searching for changes
  remote: adding changesets
  remote: adding manifests
  remote: adding file changes
  remote: added 1 changesets with 1 changes to 1 files
  $ REV=`hg log -r . --template "{node|short}"`

Close the tree

  $ autolandctl treestatus closed
  treestatus set to: closed

Post a job to land-repo

  $ autolandctl post-job test-repo $REV land-repo --commit-descriptions "{\"$REV\": \"Bug 1 - some stuff; r=cthulhu\"}"
  (200, u'{\n  "request_id": 1\n}')
  $ autolandctl job-status 1 --poll
  timed out

Open the tree

  $ autolandctl treestatus open
  treestatus set to: open
  $ autolandctl job-status 1 --poll
  (200, u'{\n  "commit_descriptions": {\n    "bdf30e77471a": "Bug 1 - some stuff; r=cthulhu"\n  }, \n  "destination": "land-repo", \n  "error_msg": "", \n  "landed": true, \n  "ldap_username": "autolanduser@example.com", \n  "result": "2d8e774dca588a8e0578f9b450c734b120a978a1", \n  "rev": "bdf30e77471a", \n  "tree": "test-repo"\n}')

Close the tree

  $ autolandctl treestatus closed
  treestatus set to: closed

Post a job to try

  $ autolandctl post-job test-repo $REV try --trysyntax "stuff"
  (200, u'{\n  "request_id": 2\n}')
  $ autolandctl job-status 2 --poll
  timed out

Open the tree

  $ autolandctl treestatus open
  treestatus set to: open
  $ autolandctl job-status 2 --poll
  (200, u'{\n  "destination": "try", \n  "error_msg": "", \n  "landed": true, \n  "ldap_username": "autolanduser@example.com", \n  "result": "c5b9e0b78b4ca6418efe8933a407b6fc25500515", \n  "rev": "bdf30e77471a", \n  "tree": "test-repo", \n  "trysyntax": "stuff"\n}') (glob)
