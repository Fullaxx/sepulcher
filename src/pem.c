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

#define _POSIX_C_SOURCE (200809L)

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char* get_pem(char *filename)
{
	FILE *f;
	ssize_t b;
	char *line, *nl, *data;
	size_t len, skip, n;

	f = fopen(filename, "r");
	if(!f) {
		fprintf(stderr, "fopen(%s, r) failed!\n", filename);
		return NULL;
	}

	n = 0;
	data = NULL;
	while(!feof(f)) {
		line = NULL;
		skip = len = 0;
		b = getline(&line, &len, f);
		if(b > 5) {
			if(strncmp(line, "-----", 5) == 0) { skip = 1; }
		}
		if((skip == 0) && (b > 0)) {
			nl = strchr(line, '\n');
			if(nl) { *nl = 0; }
			b = strlen(line);
			data = realloc(data, n+b+1);
			memcpy(data+n, line, b);
			n += b;
			data[n] = 0;
		}
		free(line);
	}
	fclose(f);
	return data;
}
