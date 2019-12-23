PERL = docker run --rm -w /app -v "$(realpath .):/app" perl:5-slim perl

release: update_version test

update_version: require_version
	$(PERL) -i -p -e 's/^(ENV FLYWAY_VERSION) .*$$/$$1 $(VERSION)/g;' Dockerfile alpine/Dockerfile
	$(PERL) -i -p \
		-e 's/`\d+\.\d+\.\d+(-alpine)?`/`$(VERSION)$$1`/g;' \
		-e 'my $$version = $$1 if ("$(VERSION)" =~ /(\d+\.\d+)\.\d+/); s/`\d+\.\d+(-alpine)?`/`$$version$$1`/g;' \
		-e 'my $$version = $$1 if ("$(VERSION)" =~ /(\d+)\.\d+\.\d+/); s/`\d+(-alpine)?`/`$$version$$1`/g;' \
		README.md

test:
	$(info Testing Docker image...)
	docker run --rm $(shell docker build -q .) -url=jdbc:h2:mem:test info

require_version:
ifndef VERSION
	$(error You must specify a VERSION variable)
endif