// Copyright (c) 2020 The PACGlobal Developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#include <amount.h>
#include <validation.h>

bool isGenerationBlock(int nHeight);
CAmount getGenerationAmount(int nHeight);
bool isGenerationRecipient(std::string recipient);