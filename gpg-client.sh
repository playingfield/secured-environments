#!/bin/bash

decrypt_vault_id() {
  local vault_id_file="${HOME}/${1}"
  gpg -q -d "${vault_id_file}" 2> >(cat >&2)
}

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --vault-id) ANSIBLE_VAULT_ID="$2"; shift ;;
  esac
  shift
done

decrypt_vault_id "${ANSIBLE_VAULT_ID}"

