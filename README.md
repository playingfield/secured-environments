# A GPG Ansible Password-Client Script

When an ansible vault_password_file is an executable script, then it is run by ansible to lookup the ansible-vault password.
When you encrypt your ansible vault password files with your GPG key and remove the plain-text files, then there is no unencrypted data at rest.
This client script decrypts a password file and passes it automatically to any  tool that supports ansible-vault.
Once you'll be prompted for your GPG passphrase, as long as gpg-agent is running, it's all transparent.



## Sensitive Data
If you need to configure systems using passwords, private keys, or API tokens, then you should ensure that access to these credentials is restricted.
Data encryption also helps against prying eyes, even people with root privileges should not have access to all data.
Staging environments and segregation of duties further improve security, and help reduce the blast radius of errors.

## Ansible Vault
If you need to store sensitive data such as passwords or tokens, then ansible-vault is an effective tool to use.
The ansible-vault command can encrypt data with a password.

## Encrypting data

To launch your favorite editor and save the text encrypted use the ansible-vault create command.
When the file exists use the ansible-vault edit command.
As you can see the file is encrypted with Advanced Encryption Standard.

```sh
$ ansible-vault create secrets.vault
New Vault password:
Confirm New Vault password:

$ ansible-vault edit secrets.vault
Vault password:
...

$ cat secrets.vault
$ANSIBLE_VAULT;1.1;AES256
30623164636337303064313565393361656437343739396235643861336265373138653965303861
3933306333636164353330393137633061653230366664310a313734323363306261353339306434
31623732373933333666656665646135656637356366646231336161323838313661636232613365
6431636132373036300a666633336135376361326163633961626231396433393533663064306336
65306365323836633838306639336230383039353035343239306432313535326633
```

## Using Encrypted Data

If a secret var is in an encrypted file named secrets.vault
ansible-playbook reads the extra file with `-e @secrets.vault`
Use -J  to be prompted for the ansible-vault password to decrypt the file

```sh
$ echo 'my_secret: vaulted' >> secrets.vault
$ ansible-vault encrypt secrets.vault
New Vault password:
Confirm New Vault password:
$ cat secrets.yml
```
```yaml
---
- name: Sensitive Data
  hosts: localhost
  become: false
  gather_facts: false
  tasks:
    - name: Report secret
      ansible.builtin.debug:
        msg: "My secret is: {{ my_secret }}"
        verbosity: 2

$ ansible-playbook -J -e @secrets.vault secrets.yml -vv
Vault password:
```

# Ansible Vault Password Security

If you need to use the ansible-vault password all day, then you need to type it all the time.
You could save the password in a vault_password_file.
Don't store the ansible-vault passwords unencrypted! Someone else will eventually find it.
Use different password for staging environments
Configure vault_password_file as a script.
The script can use a secrets management tool, or just GPG encryption.

## Configuring the Password-Client Script

The personal ~/.ansible.cfg file should have a few defaults to get to a smooth proces.
vault_password_file points to the script.
vault_identity_list maps the vault-id's their source, the script in our cases. vault_id_match = true decrypting vaults with a vault id will only try the password from the matching vault-id

```ini
[defaults]
vault_password_file = ~/gpg-client.sh
vault_identity_list = test@~/gpg-client.sh,prod@~/gpg-client.sh
vault_id_match = true
```

## Encrypting Vault Passwords

The personal ~/.ansible.cfg file can have a vault_password_file script to decrypt the ansible vault password.

```sh
# Temporarily create a plain text file with the password
$ echo $TEST_PASSWORD > ~/test
$ echo $PROD_PASSWORD > ~/prod

# Encrypt these files with your GPG key
$ gpg --encrypt -r $YOUR_EMAIL ~/test
$ gpg --encrypt -r $YOUR_EMAIL ~/prod

# Move over the plain text files
$ mv test.gpg test
$ mv prod.gpg prod

# Then we edit, and use the secret vars files transparently:
$ ansible-vault create --encrypt-vault-id prod prod.vault
$ ansible-vault edit prod.vault
$ ansible-playbook -e @prod.vault secrets.yml -vv
```



