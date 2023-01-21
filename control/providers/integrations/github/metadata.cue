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
}

versions: [_]: #Version
versions: metadata & {
	"5.14.0": {}
	"5.13.0": {}
	"5.12.0": {}
}

missing: [
	for k, v in versions if v.version == #Missing {k},
]
