$PHONY: venv

build:
	pip install -r requirements-test.txt

init:
	@echo initializing all the things...
	@tfenv install
	@terraform init
	@terraform workspace new prod
	@terraform workspace new dev
	@echo done

clean:
	@rm -rf venv
	@rm -rf lambda.zip

venv:
	# building virtualenv
	@python -m venv venv
	@venv/bin/pip install -U pip

reqs:
	@echo installing requirements...
	@venv/bin/python -m pip install -r requirements.txt > /dev/null
	@echo installed successfully

package: reqs
	@echo packaging...
	@cd venv/lib/python3.7/site-packages/ && zip -qr9 lambda.zip ./ --exclude=@../../../../zipexclude.lst
	@mv venv/lib/python3.7/site-packages/lambda.zip ./
	@zip -g lambda.zip handler.py
	@zip -rg lambda.zip {{cookiecutter.package_name}}/  --exclude=@zipexclude.lst
	@echo packaged.

plan: package
	terraform plan

deploy: package
	terraform apply -auto-approve

test:
	black --check .
	python -m mypy {{ cookiecutter.package_name }} tests handler.py
	python -m pytest tests
