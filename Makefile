test:
	docker run --rm $(shell docker build -q .) -url=jdbc:h2:mem:test info