This folder holds Goose SQL migrations.

Do not add files manually. Always use the Makefile command to generate migrations:

    make migrate-create NAME=descriptive_change

Then edit the generated file to add your SQL in the `-- +goose Up` and `-- +goose Down` sections.

Apply migrations locally:

    make migrate-up

Check status:

    make migrate-status
