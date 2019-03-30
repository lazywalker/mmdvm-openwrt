/*
# Copyright 2019 BD7MQB <bd7mqb@qq.com>
# This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0
*/
#include "DMRLookup.hpp"
#include "Utils.hpp"

#include <cstdio>
#include <cstdlib>
#include <cstring>

using namespace std;
using namespace utils;

CDMRLookup::CDMRLookup(const std::string& filename) :
m_filename(filename),
m_table() {
	// this->read();
}

CDMRLookup::~CDMRLookup() {
	delete this;
}

bool CDMRLookup::read() {
	bool ret = load();

	return ret;
}

std::string CDMRLookup::findByCallsign(std::string callsign) {
	std::string b;

	try {
		b = m_table.at(callsign);
		
	} catch (...) {
		b = std::string("0");
	}

	return b;
}

bool CDMRLookup::load() {
	FILE* fp = ::fopen(m_filename.c_str(), "rt");
	if (fp == NULL) {
		printf("Cannot open the DMR Id lookup file - %s\n", m_filename.c_str());
		return false;
	}

	m_table.clear();

	char buffer[100U];

	while (::fgets(buffer, 100U, fp) != NULL) {
		if (buffer[0U] == '#')
			continue;

		char *s = strdup(buffer);
		char* p1 = ::strsep(&s, " \t\r\n");
		char* p2 = ::strsep(&s, " \r\n");  // tokenize to eol to capture name as well

		if (p1 != NULL && p2 != NULL) {
			// unsigned int id = (unsigned int)::atoi(p1);
			for (char* p = p2; *p != 0x00U; p++) {
				if(*p == 0x09U) 
					*p = 0x20U;
				else 
					*p = ::toupper(*p);
			}
			
			std::string b = std::string(p2);
			std::string callsign;
			size_t n = b.find(" ");
			if (n > 0) {
				callsign = b.substr(0, n);
			} else {
				callsign = b;
			}
			
			// std::cout << callsign << endl;
			m_table[callsign] = rtrim(std::string(buffer));
		}
	}

	::fclose(fp);

	// std::cout << m_table.size() << endl;

	size_t size = m_table.size();
	if (size == 0U)
		return false;

	// LogInfo("Loaded %u Ids to the DMR callsign lookup table", size);

	return true;
}