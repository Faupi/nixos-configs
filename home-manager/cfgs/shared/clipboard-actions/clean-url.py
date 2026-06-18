import sys
from urllib.parse import urlparse, parse_qsl, urlencode, urlunparse

url = sys.argv[1]

tracked = {
    "utm_source",
    "utm_medium",
    "utm_campaign",
    "utm_term",
    "utm_content",
    "utm_id",
    "utm_name",
    "utm_cid",
    "utm_reader",
    "utm_referrer",
    "utm_viz_id",
    "utm_pubreferrer",
    "utm_swu",
    "fbclid",
    "gclid",
    "dclid",
    "msclkid",
    "mc_cid",
    "mc_eid",
    "_hsenc",
    "_hsmi",
    "igshid",
    "si",
}

parsed = urlparse(url)

query = [
    (k, v)
    for k, v in parse_qsl(parsed.query, keep_blank_values=True)
    if k not in tracked
]

print(
    urlunparse(
        parsed._replace(query=urlencode(query))
    )
)