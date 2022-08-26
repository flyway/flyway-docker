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

wait_for_artifacts: URL = https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/
wait_for_artifacts:
	$(info Waiting for artifacts...)
	$(BASH) -c 'until wget -q --spider --user-agent="Mozilla" $(URL)$(VERSION) &> /dev/null; do sleep 2; done'

build: URL = https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/
build:
	-docker buildx rm multi_arch_builder
	docker buildx create --name multi_arch_builder --driver-opt network=bridge --use
	docker buildx build --platform linux/arm/v7,linux/arm64/v8,linux/amd64 --pull --build-arg FLYWAY_VERSION=$(VERSION) --build-arg FLYWAY_ARTIFACT_URL=$(URL) \
	-t flyway/flyway:latest \
	-t flyway/flyway:$(VERSION) \
	-t flyway/flyway:$(subst $S,.,$(wordlist 1,2,$(subst .,$S,$(subst -,$S,$(VERSION)))))$(wordlist 2,2,$(subst -,$S-,$(VERSION))) \
	-t flyway/flyway:$(subst $S,.,$(wordlist 1,1,$(subst .,$S,$(subst -,$S,$(VERSION)))))$(wordlist 2,2,$(subst -,$S-,$(VERSION))) .
	docker build --pull --build-arg FLYWAY_VERSION=$(VERSION) --build-arg FLYWAY_ARTIFACT_URL=$(URL) \
	-t flyway/flyway:latest-alpine \
	-t flyway/flyway:$(VERSION)-alpine \
	-t flyway/flyway:$(subst $S,.,$(wordlist 1,2,$(subst .,$S,$(subst -,$S,$(VERSION)))))$(wordlist 2,2,$(subst -,$S-,$(VERSION)))-alpine \
	-t flyway/flyway:$(subst $S,.,$(wordlist 1,1,$(subst .,$S,$(subst -,$S,$(VERSION)))))$(wordlist 2,2,$(subst -,$S-,$(VERSION)))-alpine ./alpine
	docker build --pull --build-arg FLYWAY_VERSION=$(VERSION) --build-arg FLYWAY_ARTIFACT_URL=$(URL) \
	-t flyway/flyway:latest-azure \
	-t flyway/flyway:$(VERSION)-azure \
	-t flyway/flyway:$(subst $S,.,$(wordlist 1,2,$(subst .,$S,$(subst -,$S,$(VERSION)))))$(wordlist 2,2,$(subst -,$S-,$(VERSION)))-azure \
	-t flyway/flyway:$(subst $S,.,$(wordlist 1,1,$(subst .,$S,$(subst -,$S,$(VERSION)))))$(wordlist 2,2,$(subst -,$S-,$(VERSION)))-azure ./azure

build_windows: URL = https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/
build_windows:
	docker build --build-arg FLYWAY_VERSION=$(VERSION) --build-arg FLYWAY_ARTIFACT_URL=$(URL) \
    	-t flyway/flyway:latest-windowsservercore \
    	-t flyway/flyway:$(VERSION)-windowsservercore \
    	-t flyway/flyway:$(subst $S,.,$(wordlist 1,2,$(subst .,$S,$(subst -,$S,$(VERSION)))))$(wordlist 2,2,$(subst -,$S-,$(VERSION)))-windowsservercore \
    	-t flyway/flyway:$(subst $S,.,$(wordlist 1,1,$(subst .,$S,$(subst -,$S,$(VERSION)))))$(wordlist 2,2,$(subst -,$S-,$(VERSION)))-windowsservercore ./windowsservercore

test: URL = https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/
test:
	$(eval REGULAR := $(shell docker build -q --build-arg FLYWAY_VERSION=$(VERSION) --build-arg FLYWAY_ARTIFACT_URL=$(URL) .))
	$(eval ALPINE := $(shell docker build -q --build-arg FLYWAY_VERSION=$(VERSION) --build-arg FLYWAY_ARTIFACT_URL=$(URL) ./alpine))
	$(eval AZURE := $(shell docker build -q --build-arg FLYWAY_VERSION=$(VERSION) --build-arg FLYWAY_ARTIFACT_URL=$(URL) ./azure))
	docker run --rm -v $(shell pwd)/test-sql:/flyway/sql $(REGULAR) -url=jdbc:h2:mem:test info
	docker run --rm -v $(shell pwd)/test-sql:/flyway/sql $(REGULAR) -url=jdbc:h2:mem:test migrate
	docker run --rm -v $(shell pwd)/test-sql:/flyway/sql $(REGULAR) -url=jdbc:h2:mem:test clean -cleanDisabled=false
	docker run --rm -v $(shell pwd)/test-sql:/flyway/sql $(ALPINE) -url=jdbc:h2:mem:test info
	docker run --rm -v $(shell pwd)/test-sql:/flyway/sql $(ALPINE) -url=jdbc:h2:mem:test migrate
	docker run --rm -v $(shell pwd)/test-sql:/flyway/sql $(ALPINE) -url=jdbc:h2:mem:test clean -cleanDisabled=false
	docker run --rm -v $(shell pwd)/test-sql:/flyway/sql $(AZURE) flyway -url=jdbc:h2:mem:test info
	docker run --rm -v $(shell pwd)/test-sql:/flyway/sql $(AZURE) flyway -url=jdbc:h2:mem:test migrate
	docker run --rm -v $(shell pwd)/test-sql:/flyway/sql $(AZURE) flyway -url=jdbc:h2:mem:test clean -cleanDisabled=false

release: URL = https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/
release:
	docker buildx build --push --platform linux/arm/v7,linux/arm64/v8,linux/amd64 --build-arg FLYWAY_VERSION=$(VERSION) --build-arg FLYWAY_ARTIFACT_URL=$(URL) \
	-t flyway/flyway:latest \
	-t flyway/flyway:$(VERSION) \
	-t flyway/flyway:$(subst $S,.,$(wordlist 1,2,$(subst .,$S,$(subst -,$S,$(VERSION)))))$(wordlist 2,2,$(subst -,$S-,$(VERSION))) \
	-t flyway/flyway:$(subst $S,.,$(wordlist 1,1,$(subst .,$S,$(subst -,$S,$(VERSION)))))$(wordlist 2,2,$(subst -,$S-,$(VERSION))) .
	docker push -a flyway/flyway
	git commit --allow-empty -a -m 'Update to $(VERSION)'
	git tag v$(VERSION) --force
	git push origin --atomic $(shell git rev-parse --abbrev-ref HEAD) v$(VERSION) --force

release_windows: URL = https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/
release_windows:
	docker push -a flyway/flyway
