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

void print_FILE(char *ptsign, char *ctdata, char *ctsign)
{
	cJSON *root_obj;
	cJSON *file_obj;
	char *out;

	root_obj = cJSON_CreateObject();
	cJSON_AddStringToObject(root_obj, "Type", "FILE");
	cJSON_AddItemToObject(root_obj, "File", file_obj = cJSON_CreateObject());
	cJSON_AddStringToObject(file_obj, "PTSIGN", ptsign);
	cJSON_AddStringToObject(file_obj, "CTDATA", ctdata);
	cJSON_AddStringToObject(file_obj, "CTSIGN", ctsign);

	out = cJSON_Print(root_obj);
	cJSON_Delete(root_obj);
	cJSON_Minify(out);
	printf("%s\n", out);
	free(out);
}

char* import_bindata(char *filename)
{
	FILE *f;
	int b, n;
	char *data;

	f = fopen(filename, "r");
	if(!f) {
		fprintf(stderr, "fopen(%s, r) failed!\n", filename);
		return NULL;
	}

	n = 0;
	data = NULL;
	b = fgetc(f);
	while(!feof(f)) {
		data = realloc(data, n+3);
		n += snprintf(data+n, n+3, "%02x", b);
		data[n] = 0;
		b = fgetc(f);
	}
	fclose(f);
	return data;
}

int main(int argc, char *argv[])
{
	char *ptsign, *ctdata, *ctsign;

	if(argc != 4) {
		fprintf(stderr, "%s: <PTSIGN> <CTFILE> <CTSIGN>\n", argv[0]);
		return 1;
	}

	ptsign = import_bindata(argv[1]);
	if(!ptsign) { return 2; }

	ctdata = import_bindata(argv[2]);
	if(!ctdata) { return 3; }

	ctsign = import_bindata(argv[3]);
	if(!ctsign) { return 4; }

	print_FILE(ptsign, ctdata, ctsign);

	free(ptsign);
	free(ctdata);
	free(ctsign);
	return 0;
}
