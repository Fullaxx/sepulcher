/*
	sepulcher is a docker tomb for your encrypted data
	Copyright (C) 2021 Brett Kuskie <fullaxx@gmail.com>

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; version 2 of the License.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#define _ISOC99_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "cJSON.h"
#include "futils.h"

#define RSA_KEY_HEADER "-----BEGIN PUBLIC KEY-----"
#define RSA_KEY_FOOTER "-----END PUBLIC KEY-----"

#define PEM_CRT_HEADER "-----BEGIN CERTIFICATE-----"
#define PEM_CRT_FOOTER "-----END CERTIFICATE-----"

int write_id_files(char *dir, char *key, char *crt)
{
	FILE *kf, *cf;
	char path[1024];

	snprintf(path, sizeof(path), "%s/public.key", dir);
	kf = fopen(path, "w");
	if(!kf) { fprintf(stderr, "fopen(%s, w) failed!\n", path); return 10; }

	snprintf(path, sizeof(path), "%s/public.crt", dir);
	cf = fopen(path, "w");
	if(!cf) { fprintf(stderr, "fopen(%s, w) failed!\n", path); return 11; }

	fprintf(kf, "%s\n", RSA_KEY_HEADER);
	fprintf(kf, "%s\n", key);
	fprintf(kf, "%s\n", RSA_KEY_FOOTER);

	fprintf(cf, "%s\n", PEM_CRT_HEADER);
	fprintf(cf, "%s\n", crt);
	fprintf(cf, "%s\n", PEM_CRT_FOOTER);

	fclose(kf);
	fclose(cf);
	return 0;
}

char* extract_obj(cJSON *root_obj, char *jsonkey)
{
	char *type_val, *data_val;
	cJSON *type_obj;
	cJSON *id_obj;
	cJSON *data_obj;

	type_obj = cJSON_GetObjectItem(root_obj, "Type");
	if(!type_obj) { fprintf(stderr, "Invalid JSON!\n"); return NULL; }

	type_val = cJSON_GetStringValue(type_obj);
	if(!type_val) { fprintf(stderr, "Type Unknown!\n"); return NULL; }
	if(strlen(type_val) != 2) { fprintf(stderr, "Type %s Incorrect!\n", type_val); return NULL; }
	if(strcmp(type_val, "ID") != 0) { fprintf(stderr, "Type %s Incorrect!\n", type_val); return NULL; }

	id_obj = cJSON_GetObjectItem(root_obj, "Identity");
	if(!id_obj) { fprintf(stderr, "Identity object not found!\n"); return NULL; }

	data_obj = cJSON_GetObjectItem(id_obj, jsonkey);
	if(!data_obj) { fprintf(stderr, "%s not found!\n", jsonkey); return NULL; }

	data_val = cJSON_GetStringValue(data_obj);
	if(!data_val) { fprintf(stderr, "No data for %s!\n", jsonkey); }

	return data_val;
}

int main(int argc, char *argv[])
{
	int err, z;
	char *id, *key, *crt;
	cJSON *root_obj;

	if(argc != 3) {
		fprintf(stderr, "%s: <ID> <DIR>\n", argv[0]);
		return 1;
	}

	z = is_regfile(argv[1], 1);
	if(z != 1) { return 2; }
	z = is_directory(argv[2], 1);
	if(z != 1) { return 3; }

	id = get_file(argv[1]);
	if(!id) { return 4; }

	root_obj = cJSON_Parse(id);

	key = extract_obj(root_obj, "PUBKEY");
	crt = extract_obj(root_obj, "PUBCRT");

	if(key && crt) {
		err = write_id_files(argv[2], key, crt);
	} else { err = 5; }

	free(id);
	cJSON_Delete(root_obj);
	return err;
}
