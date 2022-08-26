PERL = docker run --rm -w /app -v "$(realpath .):/app" perl:5-slim perl
BASH = docker run --rm bash:5 bash
E =
S = $E $E

update_version:
	$(PERL) -i -p \
		-e 's/`\d+\.\d+\.\d+(?:-beta\d+)?(-(alpine|azure))?`/`$(VERSION)$$1`/g;' \
		-e 'my $$version = $$1 if ("$(VERSION)" =~ /(\d+\.\d+)\.\d+/); s/`\d+\.\d+(-(alpine|azure))?`/`$$version$$1`/g;' \
		-e 'my $$version = $$1 if ("$(VERSION)" =~ /(\d+)\.\d+\.\d+/); s/`\d+(-(alpine|azure))?`/`$$version$$1`/g;' \
		README.md

wait_for_artifacts: URL = https://download.red-gate.com/maven/release/org/flywaydb/enterprise/flyway-commandline/$(VERSION)/flyway-commandline-$(VERSION).tar.gz
wait_for_artifacts:
	$(info Waiting for artifacts...)
	$(BASH) -c 'until wget -q --spider --user-agent="Mozilla" $(URL) &> /dev/null; do sleep 2; done'

build:
	docker build --pull --build-arg FLYWAY_VERSION=$(VERSION) \
	-t redgate/flyway:latest \
	-t redgate/flyway:$(VERSION) \
	-t redgate/flyway:$(subst $S,.,$(wordlist 1,2,$(subst .,$S,$(subst -,$S,$(VERSION)))))$(wordlist 2,2,$(subst -,$S-,$(VERSION))) \
	-t redgate/flyway:$(subst $S,.,$(wordlist 1,1,$(subst .,$S,$(subst -,$S,$(VERSION)))))$(wordlist 2,2,$(subst -,$S-,$(VERSION))) .
	docker build --pull --build-arg FLYWAY_VERSION=$(VERSION) \
	-t redgate/flyway:latest-alpine \
	-t redgate/flyway:$(VERSION)-alpine \
	-t redgate/flyway:$(subst $S,.,$(wordlist 1,2,$(subst .,$S,$(subst -,$S,$(VERSION)))))$(wordlist 2,2,$(subst -,$S-,$(VERSION)))-alpine \
	-t redgate/flyway:$(subst $S,.,$(wordlist 1,1,$(subst .,$S,$(subst -,$S,$(VERSION)))))$(wordlist 2,2,$(subst -,$S-,$(VERSION)))-alpine ./alpine
	docker build --pull --build-arg FLYWAY_VERSION=$(VERSION) \
	-t redgate/flyway:latest-azure \
	-t redgate/flyway:$(VERSION)-azure \
	-t redgate/flyway:$(subst $S,.,$(wordlist 1,2,$(subst .,$S,$(subst -,$S,$(VERSION)))))$(wordlist 2,2,$(subst -,$S-,$(VERSION)))-azure \
	-t redgate/flyway:$(subst $S,.,$(wordlist 1,1,$(subst .,$S,$(subst -,$S,$(VERSION)))))$(wordlist 2,2,$(subst -,$S-,$(VERSION)))-azure ./azure

build_windows:
	docker build --build-arg FLYWAY_VERSION=$(VERSION) \
    	-t redgate/flyway:latest-windowsservercore \
    	-t redgate/flyway:$(VERSION)-windowsservercore \
    	-t redgate/flyway:$(subst $S,.,$(wordlist 1,2,$(subst .,$S,$(subst -,$S,$(VERSION)))))$(wordlist 2,2,$(subst -,$S-,$(VERSION)))-windowsservercore \
    	-t redgate/flyway:$(subst $S,.,$(wordlist 1,1,$(subst .,$S,$(subst -,$S,$(VERSION)))))$(wordlist 2,2,$(subst -,$S-,$(VERSION)))-windowsservercore ./windowsservercore

test:
	$(eval REGULAR := $(shell docker build -q --build-arg FLYWAY_VERSION=$(VERSION) .))
	$(eval ALPINE := $(shell docker build -q --build-arg FLYWAY_VERSION=$(VERSION) ./alpine))
	$(eval AZURE := $(shell docker build -q --build-arg FLYWAY_VERSION=$(VERSION) ./azure))
	docker run --rm -v $(shell pwd)/../test-sql:/flyway/sql $(REGULAR) -licenseKey="$(KEY)" -url=jdbc:h2:mem:test info
	docker run --rm -v $(shell pwd)/../test-sql:/flyway/sql $(REGULAR) -licenseKey="$(KEY)" -url=jdbc:sqlite:test check -changes -code -check.buildUrl=jdbc:sqlite:temp -check.reportFilename=report
	docker run --rm -v $(shell pwd)/../test-sql:/flyway/sql $(REGULAR) -licenseKey="$(KEY)" -url=jdbc:h2:mem:test migrate
	docker run --rm -v $(shell pwd)/../test-sql:/flyway/sql $(REGULAR) -licenseKey="$(KEY)" -url=jdbc:h2:mem:test clean -cleanDisabled=false
	docker run --rm -v $(shell pwd)/../test-sql:/flyway/sql $(ALPINE) -licenseKey="$(KEY)" -url=jdbc:h2:mem:test info
	docker run --rm -v $(shell pwd)/../test-sql:/flyway/sql $(ALPINE) -licenseKey="$(KEY)" -url=jdbc:sqlite:test check -changes -code -check.buildUrl=jdbc:sqlite:temp -check.reportFilename=report
	docker run --rm -v $(shell pwd)/../test-sql:/flyway/sql $(ALPINE) -licenseKey="$(KEY)" -url=jdbc:h2:mem:test migrate
	docker run --rm -v $(shell pwd)/../test-sql:/flyway/sql $(ALPINE) -licenseKey="$(KEY)" -url=jdbc:h2:mem:test clean -cleanDisabled=false
	docker run --rm -v $(shell pwd)/../test-sql:/flyway/sql $(AZURE) flyway -licenseKey="$(KEY)" -url=jdbc:h2:mem:test info
	docker run --rm -v $(shell pwd)/../test-sql:/flyway/sql $(AZURE) flyway -licenseKey="$(KEY)" -url=jdbc:sqlite:test check -changes -code -check.buildUrl=jdbc:sqlite:temp -check.reportFilename=report
	docker run --rm -v $(shell pwd)/../test-sql:/flyway/sql $(AZURE) flyway -licenseKey="$(KEY)" -url=jdbc:h2:mem:test migrate
	docker run --rm -v $(shell pwd)/../test-sql:/flyway/sql $(AZURE) flyway -licenseKey="$(KEY)" -url=jdbc:h2:mem:test clean -cleanDisabled=false

release:
	docker push -a redgate/flyway
	git commit --allow-empty -a -m 'Update to $(VERSION)'
	git tag v$(VERSION) --force
	git push origin --atomic $(shell git rev-parse --abbrev-ref HEAD) v$(VERSION) --force

release_windows:
	docker push -a redgate/flyway
