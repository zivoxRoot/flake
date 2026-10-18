# Secrets management

**Tools used**:
- sops
- age
- sops-nix

## Sops setup

1. Create a new key

```bash
mkdir -p ~/.config/sops/age
```

2. Generate a new key pair

```bash
age-keygen -o ~/.config/sops/age
```

## Sops usage

Create a secrets.yaml file storing secrets that we will encrypt

```bash
echo <<'EOF' > secrets.yaml
username: my-username
password: this-is-a-fake-password
ssh:
  hostname: example.com
  private_key: this-is-not-a-real-private-key
EOF
```

1. Encrypt the secret file

```bash
sops encrypt --age <public-key> --in-place secrets.yaml
```

2. Decrypt or edit the file

```bash
sops decrypt secrets.yaml
sops edit secrets.yaml # 'edit' can be omitted
```
