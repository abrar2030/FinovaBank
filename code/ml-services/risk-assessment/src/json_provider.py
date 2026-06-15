"""JSON provider that makes numpy and pandas results safe to serialize.

The analytics and risk routes return values produced by numpy and pandas
(for example numpy.int64 hour keys, numpy.float64 statistics, pandas Period
month keys, and MultiIndex tuple keys from grouped aggregations). Flask's
default JSON provider cannot serialize these types, which previously caused
several endpoints to return HTTP 500 with
"Object of type int64 is not JSON serializable".

This provider recursively coerces those values into native JSON types before
serialization, covering both dict values and dict keys.
"""

from flask.json.provider import DefaultJSONProvider

try:
    import numpy as np
except ImportError:  # pragma: no cover - numpy is a declared dependency
    np = None

try:
    import pandas as pd
except ImportError:  # pragma: no cover - pandas is a declared dependency
    pd = None


def _coerce(value):
    """Recursively convert numpy/pandas objects into JSON-native types."""
    if np is not None:
        if isinstance(value, np.integer):
            return int(value)
        if isinstance(value, np.floating):
            return float(value)
        if isinstance(value, np.bool_):
            return bool(value)
        if isinstance(value, np.ndarray):
            return [_coerce(item) for item in value.tolist()]

    if pd is not None:
        if isinstance(value, pd.Timestamp):
            return value.isoformat()
        if isinstance(value, pd.Period):
            return str(value)

    if isinstance(value, dict):
        return {_coerce_key(key): _coerce(item) for key, item in value.items()}
    if isinstance(value, (list, tuple, set)):
        return [_coerce(item) for item in value]

    return value


def _coerce_key(key):
    """Coerce a dict key into a JSON-valid key type."""
    coerced = _coerce(key)
    if isinstance(coerced, (str, int, float, bool)) or coerced is None:
        return coerced
    # Tuple keys (e.g. from MultiIndex aggregations) and any other complex
    # key types are flattened to a stable string representation.
    if isinstance(coerced, (list, tuple)):
        return ".".join(str(part) for part in coerced)
    return str(coerced)


class NumpyJSONProvider(DefaultJSONProvider):
    """DefaultJSONProvider that first normalizes numpy/pandas values."""

    def dumps(self, obj, **kwargs):
        return super().dumps(_coerce(obj), **kwargs)
