/*
# Copyright 2019 BD7MQB <bd7mqb@qq.com>
# This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0
*/
#ifndef	__DMRLOOKUP__
#define	__DMRLOOKUP__

#include <string>
#include <unordered_map>

class CDMRLookup {
public:
	CDMRLookup(const std::string& filename);
	virtual ~CDMRLookup();

	bool read();

	std::string findByCallsign(std::string callsign);

private:
	std::string m_filename;
	std::unordered_map<std::string, std::string> m_table;

	bool load();
};

#endif
