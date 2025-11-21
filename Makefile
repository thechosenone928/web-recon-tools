
push:
	docker buildx build \
      --platform linux/amd64,linux/arm64 \
      -t tco/web-recon-tools:latest \
      --push \
      -f Dockerfile .

install:
	go install github.com/owasp-amass/amass/v4/...@master
	go install github.com/tomnomnom/anew@latest
	go install github.com/tomnomnom/assetfinder@latest
	go install github.com/tomnomnom/httprobe@latest
	go install github.com/tomnomnom/fff@latest
	go install github.com/projectdiscovery/httpx/cmd/httpx@latest
	go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
	go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
	go install github.com/projectdiscovery/katana/cmd/katana@latest
	go install github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
	go install github.com/ffuf/ffuf/v2@latest
	go install github.com/jaeles-project/gospider@latest
	go install github.com/OJ/gobuster/v3@latest
