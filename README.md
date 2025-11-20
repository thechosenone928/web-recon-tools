# pentest-tools

This Docker image comes preloaded with reconnaissance & penetration testing tools:

- [Rustscan](https://github.com/RustScan/RustScan)  
- [Aquatone](https://github.com/michenriksen/aquatone)  
- [Metabigor](https://github.com/j3ssie/metabigor)  
- [sqlmap](https://sqlmap.org/)  
- [arjun](https://github.com/s0md3v/Arjun)  
- [dirsearch](https://github.com/maurosoria/dirsearch)  
- [git-dumper](https://github.com/arthaud/git-dumper)  
- Chromium headless for automation  
- SSH server for remote access

---

## 🚀 Build Image

```bash
docker compose build
```

---

## ▶️ Run Container

Run the container and expose the SSH port (22):

```bash
docker-compose up
```

---

## 🔑 SSH Login

The container is configured with SSH root login enabled.

* **User**: `root`
* **Password**: `recon`

Connect via SSH:

```bash
ssh root@127.0.0.1 -p 22222
```

---

## 🛠 Usage Examples

Once inside the container:

```bash
# Port scanning with Rustscan
rustscan -a 127.0.0.1

# Subdomain discovery with Metabigor
metabigor net --org google

# Endpoint discovery with Arjun
arjun -u https://target.com

# SQL Injection test
sqlmap -u "https://target.com/page.php?id=1" --batch
```
