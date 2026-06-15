import os
import tempfile

import pytest

# Use an isolated throwaway SQLite database for the test session. This must be
# set before src.main is imported, because the app initializes the database at
# import time.
os.environ.setdefault(
    "DATABASE_URL",
    "sqlite:///" + os.path.join(tempfile.gettempdir(), "ai_service_test.db"),
)


@pytest.fixture(scope="session")
def app():
    from src.main import app as flask_app

    flask_app.config.update(TESTING=True)
    return flask_app


@pytest.fixture()
def client(app):
    return app.test_client()
