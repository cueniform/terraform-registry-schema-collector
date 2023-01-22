package metadata

import (
	"strings"
	"cueniform.com/collector/schemata/providers/integrations/github:metadata"
)

missing_text: strings.Join(missing, "\n")

#Missing: "MISSING"
#Version: {
	provider: string | *#Missing
	version:  string | *#Missing
	...
}

versions: [_]: #Version
versions: metadata & {
	"5.16.0": {}
	"5.15.0": {}
	"5.14.0": {}
	"5.13.0": {}
	"5.12.0": {}
	"5.11.0": {}
	"5.10.0": {}
	"5.9.2": {}
	"5.9.1": {}
	"5.9.0": {}
}

missing: [
	for k, v in versions if v.version == #Missing {k},
]
