// Code generated by oapi-codegen. DO NOT EDIT.
// Package server provides primitives to interact the openapi HTTP API.
//
// Code generated by github.com/deepmap/oapi-codegen DO NOT EDIT.
package server

import (
	"bytes"
	"compress/gzip"
	"encoding/base64"
	"fmt"
	"github.com/getkin/kin-openapi/openapi3"
	"strings"
)

// Base64 encoded, gzipped, json marshaled Swagger object
var swaggerSpec = []string{

	"H4sIAAAAAAAC/+xYbW/bNhD+KwK3D1shhXIGFK2GYfNaxwiaxZ6bfdjawGCks81WIjmSSusZ+u8DKVlv",
	"VlzbtZti2DebL8/dPXcPdeQKhTwRnAHTCgUrJIgkCWiQ9p8mcg7a/Ao508DsTw0fNRYxoexHJ1wQqUD/",
	"lOqZ98xMwkeSiBhQgCjTIBmJkYtUuICE2L1LYeaUlpTNUZZlLopAhZIKTTlDQWHR+S6CexqCQ5nDGVde",
	"yNmMzr9HLqJmlSB6gVzESALlHuQiCX+nVEKEAi1TMOBmBJT+lUcUbESTcmA5ndyRsBUbESKmITHO4HfK",
	"eLSqef+thBkK0De44gznswpbsMxG1LYxHUqeiqNaKiC32ZtOuMnD0Y3muA9YPr7NT1mbjkEmVCmaIx/X",
	"cB08y50o1hiIfhRRg07iseQCpF7elHppVvUfCiJnxqWTiohoUMhFIt9SlGUltLZC3PUIv3sHoUaGh6Ju",
	"Sdt+AbYttAd9ztoulUVLNSRqn6J0kabangGXGpLaTBkLkZIsbShFvexuI6+HDhN2om2httCy9gCblUJP",
	"y+n+4dYlV4ulK9bWUbpCCfl4BWyuFyjo+b6LEsrK/xVWfZPbLj8XzY0DNLJ4jf2CaHPAowC9Id4/fe+v",
	"6W3xw/eev33rTc9un6DKzBrH3bXCW6fYaRNzCuYkjyEnbr2hGNmdgi8TfPME3f9gdE9M32fV3UGctz4q",
	"p6U/BjLzYqq0x3jKGsdDjcjzTSIrJnCDATw9e/JzgwQL3MHxer7lwubJYvwl6/QCSxMUvEH9qyvkoheT",
	"Qf9mgFw0GfRfotsKtNrTZdkOVFgvRtcXl0PkouFk/KKOYhd2Zq92rm8kbSO5ZgdlM77uEUhov7aQEBrb",
	"ZnXGf+ECGAP9gcv3lM3PuJxXPeZIAHOuy0nngqcsWkeXSoOx0FqoAOMOmMxFMQ2BKRtzAXmVj0xg5o2u",
	"L7zfILkD6fXO/B0Q8QfhFa0OTkXMSaTwuX/uY/8proGNWLz0XvOZ/kAkeIVB77535p+JaGbzADJRo9lr",
	"kKbfPsBm7zn2z63NHJ6yuUdY5F2OJ95F/3fPeOX5T629ZtLqnb2T8AhiR8TpnBpG70Hm4kPGV78oQUYE",
	"RQH6wQ7Z+l9YmWB5R0Jsw/LxKu+lMjuYn+0xaEt8WZGXEQrQSztetAUSlOBMrb8GM5LGHX2cLTyVJgmR",
	"S4MwuBrcDJwhMINrWjzJE+fP/vUwj8d+P/O2rml6CLrL7rnvH/0+0r5gDQc3zuiVY0w1gzETlrMt8bhI",
	"k7kyekW35hyrXRbfdLtTLcFFj5vdukhw1cHKmKuKlrLVfyjQxtUOb9zrsg1ue5v5DCWYOFtMjEevb7Yl",
	"NXO3VBy2jQ5eFf1OtlsFrvvjRynDTuPHrsXqxrp/Reac7lSXNVOHV6i7+3vHHk8b72HpVGXR+ZJRNcmt",
	"p4xPaqbK4WcKp7rEfRXywaZ/w6u8i9tHTMUV6fEE1eXAaURVvpEcqqwW3XsKLTf/X1LbCT1aF3KnQ+Vd",
	"5SD1lwV3lBOgfHN4nGPgANk/puK/iNg/Q+b7yfrrFfRp5HM05XxFmsGi8YSxm3waN+hHE9LDXpxEUq1H",
	"/gPV1UX8/4rbprhWmo+hvdaz5MlkaFaDvF9nqXqtCTAmoBcgPclDjwiK2qS+Su9AMtCgnDGPHBKGoJQj",
	"OGV5HhtYMQ9JvOBKB896z3obWFdmugVxm/0bAAD//4NNRKjTHQAA",
}

// GetSwagger returns the Swagger specification corresponding to the generated code
// in this file.
func GetSwagger() (*openapi3.Swagger, error) {
	zipped, err := base64.StdEncoding.DecodeString(strings.Join(swaggerSpec, ""))
	if err != nil {
		return nil, fmt.Errorf("error base64 decoding spec: %s", err)
	}
	zr, err := gzip.NewReader(bytes.NewReader(zipped))
	if err != nil {
		return nil, fmt.Errorf("error decompressing spec: %s", err)
	}
	var buf bytes.Buffer
	_, err = buf.ReadFrom(zr)
	if err != nil {
		return nil, fmt.Errorf("error decompressing spec: %s", err)
	}

	swagger, err := openapi3.NewSwaggerLoader().LoadSwaggerFromData(buf.Bytes())
	if err != nil {
		return nil, fmt.Errorf("error loading Swagger: %s", err)
	}
	return swagger, nil
}
