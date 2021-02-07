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
#include <ctype.h>

#include "cJSON.h"
#include "futils.h"

int dump_bindata(FILE *f, char *buf)
{
	int err, len;
	unsigned long b;
	char hexd[3] = {0,0,0};

	len = strlen(buf);
	while(len > 1) {
		hexd[0] = buf[0];
		hexd[1] = buf[1];
		if(!isxdigit(hexd[0])) { return 1; }
		if(!isxdigit(hexd[1])) { return 1; }

		b = strtoul(&hexd[0], NULL, 16);
		err = fputc(b, f);
		if(err == EOF) { return 2; }

		buf += 2;
		len -= 2;
	}

	return 0;
}

int write_files(char *dir, char *ptsign, char *ctdata, char *ctsign)
{
	int err;
	char path[1024];
	FILE *ptsf, *ctf, *ctsf;

	snprintf(path, sizeof(path), "%s/pt.sign", dir);
	ptsf = fopen(path, "w");
	if(!ptsf) { fprintf(stderr, "fopen(%s, w) failed!\n", path); return 10; }

	snprintf(path, sizeof(path), "%s/ct.data", dir);
	ctf = fopen(path, "w");
	if(!ctf) { fprintf(stderr, "fopen(%s, w) failed!\n", path); return 11; }

	snprintf(path, sizeof(path), "%s/ct.sign", dir);
	ctsf = fopen(path, "w");
	if(!ctsf) { fprintf(stderr, "fopen(%s, w) failed!\n", path); return 12; }

	err = dump_bindata(ptsf, ptsign);
	if(err) { fprintf(stderr, "dump_signature(%s/pt.sign) failed!\n", dir); return 13; }

	err = dump_bindata(ctf, ctdata);
	if(err) { fprintf(stderr, "dump_signature(%s/ct.data) failed!\n", dir); return 14; }

	err = dump_bindata(ctsf, ctsign);
	if(err) { fprintf(stderr, "dump_signature(%s/ct.sign) failed!\n", dir); return 15; }

	fclose(ptsf);
	fclose(ctf);
	fclose(ctsf);
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
	if(strlen(type_val) != 4) { fprintf(stderr, "Type %s Incorrect!\n", type_val); return NULL; }
	if(strcmp(type_val, "FILE") != 0) { fprintf(stderr, "Type %s Incorrect!\n", type_val); return NULL; }

	id_obj = cJSON_GetObjectItem(root_obj, "File");
	if(!id_obj) { fprintf(stderr, "File object not found!\n"); return NULL; }

	data_obj = cJSON_GetObjectItem(id_obj, jsonkey);
	if(!data_obj) { fprintf(stderr, "%s not found!\n", jsonkey); return NULL; }

	data_val = cJSON_GetStringValue(data_obj);
	if(!data_val) { fprintf(stderr, "No data for %s!\n", jsonkey); }

	return data_val;
}

int main(int argc, char *argv[])
{
	int err, z;
	char *bundle, *ptsign, *ctdata, *ctsign;
	cJSON *root_obj;

	if(argc != 3) {
		fprintf(stderr, "%s: <BUNDLE> <DIR>\n", argv[0]);
		return 1;
	}

	z = is_regfile(argv[1], 1);
	if(z != 1) { return 2; }
	z = is_directory(argv[2], 1);
	if(z != 1) { return 3; }

	bundle = get_file(argv[1]);
	if(!bundle) { return 4; }

	root_obj = cJSON_Parse(bundle);

	ptsign = extract_obj(root_obj, "PTSIGN");
	ctdata = extract_obj(root_obj, "CTDATA");
	ctsign = extract_obj(root_obj, "CTSIGN");

	if(ptsign && ctdata && ctsign) {
		err = write_files(argv[2], ptsign, ctdata, ctsign);
	} else { err = 5; }

	free(bundle);
	cJSON_Delete(root_obj);
	return err;
}
