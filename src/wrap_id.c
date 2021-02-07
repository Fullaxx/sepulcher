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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "cJSON.h"
#include "pem.h"

void print_ID(char *pubkey, char *pubcrt)
{
	cJSON *root_obj;
	cJSON *id_obj;
	char *out;

	root_obj = cJSON_CreateObject();
	cJSON_AddStringToObject(root_obj, "Type", "ID");
	cJSON_AddItemToObject(root_obj, "Identity", id_obj = cJSON_CreateObject());
	cJSON_AddStringToObject(id_obj, "PUBKEY", pubkey);
	cJSON_AddStringToObject(id_obj, "PUBCRT", pubcrt);

	out = cJSON_Print(root_obj);
	cJSON_Delete(root_obj);
	cJSON_Minify(out);
	printf("%s", out);
	free(out);
}

int main(int argc, char *argv[])
{
	char *key, *crt;

	if(argc != 3) {
		fprintf(stderr, "%s: <PUBKEY> <PUBCRT>\n", argv[0]);
		return 1;
	}

	key = get_pem(argv[1]);
	if(!key) { return 2; }

	crt = get_pem(argv[2]);
	if(!crt) { return 3; }

	print_ID(key, crt);

	free(key);
	free(crt);
	return 0;
}
