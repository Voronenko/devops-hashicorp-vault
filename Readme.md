
Unsorted notes

Demo root token  789XX6e5-XXXX-3c96-99f7-XXXXX

Demo key 1  WC8PhXXXX9VAwxYP8PuYXLoyxd7M+XXXXXXXX


================================================


Great resource is   https://learn.hashicorp.com/vault/

Things to try


vault login
(token)

vault status

vault kv put secret/hello foo=world


vault kv get secret/hello


vault kv get -format=json secret/hello

vault kv get -format=json secret/hello | jq -r .data.excited

vault kv get -field=excited secret/hello


Just like a filesystem, Vault can enable a secrets engine at many different paths. Each path is completely isolated and cannot talk to other paths. For example, a kv secrets engine enabled at foo has no ability to communicate with a kv secrets engine enabled at bar


vault secrets enable -path=kv kv


vault secrets list
Path          Type         Accessor              Description
----          ----         --------              -----------
cubbyhole/    cubbyhole    cubbyhole_09638d43    per-token private secret storage
identity/     identity     identity_a1a80c13     identity store
kv/           kv           kv_cc44a09b           n/a
secret/       kv           kv_67ccff83           key/value secret storage
sys/          system       system_eb8c2cdd       system endpoints used for control, policy and debugging




vault secrets disable kv/


=========================================

Integrate with AWS

vault secrets enable -path=aws aws

vault write aws/config/root \
    access_key=${AWS_ACCESS_KEY_ID} \
    secret_key=${AWS_SECRET_ACCESS_KEY} \
    region=${AWS_DEFAULT_REGION}



The next step is to configure a role. A role in Vault is a human-friendly identifier to an action. Think of it as a symlink.

Vault knows how to create an IAM user via the AWS API, but it does not know what permissions, groups, and policies you want to attach to that user. This is where roles come in - roles map your configuration options to those API calls.



vault write aws/roles/my-role \
        credential_type=iam_user \
        policy_document=-<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1426528957000",
      "Effect": "Allow",
      "Action": [
        "ec2:*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF


vault read aws/creds/my-role
Key                Value
---                -----
lease_id           aws/creds/my-role/0bce0782-32aa-25ec-f61d-c026ff22106e
lease_duration     768h
lease_renewable    true
access_key         AKIAJELXXXXXXX
secret_key         WWeSnj00W+hHoHJMCXXXXXXXXXXXXXXXXX
security_token     <nil>


Each run access key  / secret key change.


Success! The access and secret key can now be used to perform any EC2 operations within AWS. Notice that these keys are new, they are not the keys you entered earlier. If you were to run the command a second time, you would get a new access key pair. Each time you read from aws/creds/:name, Vault will connect to AWS and generate a new IAM user and key pair.

Take careful note of the lease_id field in the output. This value is used for renewal, revocation, and inspection. Copy this lease_id to your clipboard. Note that the lease_id is the full path, not just the UUID at the end.

User names are generated like   vault-root-my-role-1542367188-3540

drop users/access

vault lease revoke aws/creds/my-role/0bce0782-32aa-25ec-f61d-c026ff22106
vault lease revoke aws/creds/my-role/c7a7c0ce-7e09-a5ae-d5c0-dbbf3eea326b

===========================

vault path-help aws

dynamically informs what backend serves here.


============================================

Tokens

Token authentication is enabled by default in Vault and cannot be disabled

The "child" concept here is important: tokens always have a parent, and when that parent token is revoked, children can also be revoked all in one operation. This makes it easy when removing access for a user, to remove access for all sub-tokens that user created as well.


In practice, operators should not use the token create command to generate Vault tokens for users or machines. Instead, those users or machines should authenticate to Vault using any of Vault's configured auth methods such as GitHub, LDAP, AppRole, etc. For legacy applications which cannot generate their own token, operators may need to create a token in advance



======================================

Auth with github

vault auth enable -path=github github


Next, configure the GitHub auth method. Each auth method has different configuration options, so please see the documentation for the full details. In this case, the minimal set of configuration is to map teams to policies.


vault write auth/github/config organization=softasap

vault write auth/github/map/teams/Owners value=default
Success! Data written to: auth/github/map/teams/Owners


==============================================

vault auth list
Path       Type      Accessor                Description
----       ----      --------                -----------
github/    github    auth_github_b740c9a4    n/a
token/     token     auth_token_5f009385     token based credentials


Thus allows to map users per github organization teams


=====================================


Can use consul as a backend


storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault/"
}

listener "tcp" {
 address     = "127.0.0.1:8200"
 tls_disable = 1
}


==========================================





