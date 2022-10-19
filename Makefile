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

wait_for_artifacts: URL = https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/$(VERSION)
wait_for_artifacts:
	$(info Waiting for artifacts...)
	$(BASH) -c 'until wget -q --spider --user-agent="Mozilla" $(URL) &> /dev/null; do sleep 2; done'

build: URL = https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/
build: EDITION = flyway
build: PLATFORM = linux/arm/v7,linux/arm64/v8,linux/amd64
build:
	-docker buildx rm multi_arch_builder
	docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
	docker buildx create --name multi_arch_builder --driver docker-container --driver-opt network=bridge --use
	docker buildx build --target $(EDITION) --platform $(PLATFORM) --pull --build-arg FLYWAY_VERSION=$(VERSION) --build-arg FLYWAY_ARTIFACT_URL=$(URL) \
	-t $(EDITION)/flyway:latest \
	-t $(EDITION)/flyway:$(VERSION) \
	-t $(EDITION)/flyway:$(subst $S,.,$(wordlist 1,2,$(subst .,$S,$(subst -,$S,$(VERSION)))))$(wordlist 2,2,$(subst -,$S-,$(VERSION))) \
	-t $(EDITION)/flyway:$(subst $S,.,$(wordlist 1,1,$(subst .,$S,$(subst -,$S,$(VERSION)))))$(wordlist 2,2,$(subst -,$S-,$(VERSION))) .
	docker build --target $(EDITION) --pull --build-arg FLYWAY_VERSION=$(VERSION) --build-arg FLYWAY_ARTIFACT_URL=$(URL) \
	-t $(EDITION)/flyway:latest-alpine \
	-t $(EDITION)/flyway:$(VERSION)-alpine \
	-t $(EDITION)/flyway:$(subst $S,.,$(wordlist 1,2,$(subst .,$S,$(subst -,$S,$(VERSION)))))$(wordlist 2,2,$(subst -,$S-,$(VERSION)))-alpine \
	-t $(EDITION)/flyway:$(subst $S,.,$(wordlist 1,1,$(subst .,$S,$(subst -,$S,$(VERSION)))))$(wordlist 2,2,$(subst -,$S-,$(VERSION)))-alpine ./alpine
	docker build --target $(EDITION) --pull --build-arg FLYWAY_VERSION=$(VERSION) --build-arg FLYWAY_ARTIFACT_URL=$(URL) \
	-t $(EDITION)/flyway:latest-azure \
	-t $(EDITION)/flyway:$(VERSION)-azure \
	-t $(EDITION)/flyway:$(subst $S,.,$(wordlist 1,2,$(subst .,$S,$(subst -,$S,$(VERSION)))))$(wordlist 2,2,$(subst -,$S-,$(VERSION)))-azure \
	-t $(EDITION)/flyway:$(subst $S,.,$(wordlist 1,1,$(subst .,$S,$(subst -,$S,$(VERSION)))))$(wordlist 2,2,$(subst -,$S-,$(VERSION)))-azure ./azure

test: URL = https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/
test: EDITION = flyway
test:
	$(eval REGULAR := $(shell docker build -q --target $(EDITION) --build-arg FLYWAY_VERSION=$(VERSION) --build-arg FLYWAY_ARTIFACT_URL=$(URL) .))
	docker run --rm -v $(shell pwd)/test-sql:/flyway/sql $(REGULAR) -url=jdbc:h2:mem:test info $(EXTRA_ARGS)
	docker run --rm -v $(shell pwd)/test-sql:/flyway/sql $(REGULAR) -url=jdbc:h2:mem:test migrate $(EXTRA_ARGS)
	docker run --rm -v $(shell pwd)/test-sql:/flyway/sql $(REGULAR) -url=jdbc:h2:mem:test clean -cleanDisabled=false $(EXTRA_ARGS)
	docker run --rm -v $(shell pwd)/test-sql:/flyway/sql $(REGULAR) check -code -check.reportFilename=report $(EXTRA_ARGS)
	docker run --rm -v $(shell pwd)/test-sql:/flyway/sql $(EDITION)/flyway:$(VERSION)-alpine -url=jdbc:h2:mem:test info $(EXTRA_ARGS)
	docker run --rm -v $(shell pwd)/test-sql:/flyway/sql $(EDITION)/flyway:$(VERSION)-alpine -url=jdbc:h2:mem:test migrate $(EXTRA_ARGS)
	docker run --rm -v $(shell pwd)/test-sql:/flyway/sql $(EDITION)/flyway:$(VERSION)-alpine -url=jdbc:h2:mem:test clean -cleanDisabled=false $(EXTRA_ARGS)
	docker run --rm -v $(shell pwd)/test-sql:/flyway/sql $(EDITION)/flyway:$(VERSION)-alpine check -code -check.reportFilename=report $(EXTRA_ARGS)
	docker run --rm -v $(shell pwd)/test-sql:/flyway/sql $(EDITION)/flyway:$(VERSION)-azure flyway -url=jdbc:h2:mem:test info $(EXTRA_ARGS)
	docker run --rm -v $(shell pwd)/test-sql:/flyway/sql $(EDITION)/flyway:$(VERSION)-azure flyway -url=jdbc:h2:mem:test migrate $(EXTRA_ARGS)
	docker run --rm -v $(shell pwd)/test-sql:/flyway/sql $(EDITION)/flyway:$(VERSION)-azure flyway -url=jdbc:h2:mem:test clean -cleanDisabled=false $(EXTRA_ARGS)
	docker run --rm -v $(shell pwd)/test-sql:/flyway/sql $(EDITION)/flyway:$(VERSION)-azure flyway check -code -check.reportFilename=report $(EXTRA_ARGS)

test_teams: URL = https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/
test_teams: test
	docker run --rm -v $(shell pwd)/test-sql:/flyway/sql ${EXTRA_DOCKER_ARGS} $(shell docker build -q --target $(EDITION) --build-arg FLYWAY_VERSION=$(VERSION) --build-arg FLYWAY_ARTIFACT_URL=$(URL) .) -url=jdbc:sqlite:test check -changes -code -check.buildUrl=jdbc:sqlite:temp -check.reportFilename=report $(EXTRA_ARGS)
	docker run --rm -v $(shell pwd)/test-sql:/flyway/sql ${EXTRA_DOCKER_ARGS} $(EDITION)/flyway:$(VERSION)-alpine -url=jdbc:sqlite:test check -changes -code -check.buildUrl=jdbc:sqlite:temp -check.reportFilename=report $(EXTRA_ARGS)
	docker run --rm -v $(shell pwd)/test-sql:/flyway/sql ${EXTRA_DOCKER_ARGS} $(EDITION)/flyway:$(VERSION)-azure flyway -url=jdbc:sqlite:test check -changes -code -check.buildUrl=jdbc:sqlite:temp -check.reportFilename=report $(EXTRA_ARGS)

release: URL = https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/
release: EDITION = flyway
release: PLATFORM = linux/arm/v7,linux/arm64/v8,linux/amd64
release:
	docker buildx build --target $(EDITION) --push --platform $(PLATFORM) --build-arg FLYWAY_VERSION=$(VERSION) --build-arg FLYWAY_ARTIFACT_URL=$(URL) \
	-t $(EDITION)/flyway:latest \
	-t $(EDITION)/flyway:$(VERSION) \
	-t $(EDITION)/flyway:$(subst $S,.,$(wordlist 1,2,$(subst .,$S,$(subst -,$S,$(VERSION)))))$(wordlist 2,2,$(subst -,$S-,$(VERSION))) \
	-t $(EDITION)/flyway:$(subst $S,.,$(wordlist 1,1,$(subst .,$S,$(subst -,$S,$(VERSION)))))$(wordlist 2,2,$(subst -,$S-,$(VERSION))) .

	docker push $(EDITION)/flyway:latest-alpine
	docker push $(EDITION)/flyway:$(VERSION)-alpine
	docker push $(EDITION)/flyway:$(subst $S,.,$(wordlist 1,2,$(subst .,$S,$(subst -,$S,$(VERSION)))))$(wordlist 2,2,$(subst -,$S-,$(VERSION)))-alpine
	docker push $(EDITION)/flyway:$(subst $S,.,$(wordlist 1,1,$(subst .,$S,$(subst -,$S,$(VERSION)))))$(wordlist 2,2,$(subst -,$S-,$(VERSION)))-alpine

	docker push $(EDITION)/flyway:latest-azure
	docker push $(EDITION)/flyway:$(VERSION)-azure
	docker push $(EDITION)/flyway:$(subst $S,.,$(wordlist 1,2,$(subst .,$S,$(subst -,$S,$(VERSION)))))$(wordlist 2,2,$(subst -,$S-,$(VERSION)))-azure
	docker push $(EDITION)/flyway:$(subst $S,.,$(wordlist 1,1,$(subst .,$S,$(subst -,$S,$(VERSION)))))$(wordlist 2,2,$(subst -,$S-,$(VERSION)))-azure

	git commit --allow-empty -a -m 'Update to $(VERSION)'
	git tag v$(VERSION) --force
	git push origin --atomic $(shell git rev-parse --abbrev-ref HEAD) v$(VERSION) --force
