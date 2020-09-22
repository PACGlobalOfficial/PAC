// Copyright (c) 2020 The PACGlobal Developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#include <amount.h>
#include <validation.h>

//! created to move away the adhoc creation of PAC required on three occasions,
//! both to keep things neat and also to serve as a visible record.
//!
//! owing to the amount of time passed since each was generated, we simply
//! test for height and amount (via exception), rather than matching script/payee etc for
//! speed during initial sync/validation.

typedef std::map<int, CAmount> GeneratedFunds;

const GeneratedFunds creationPoints = {
    { 362250, 700000000 * COIN },
    { 387989, 1000000000 * COIN },
    { 545600, 840686520 * COIN },
};

bool isGenerationBlock(int nHeight)
{
    for (auto genpairs : creationPoints)
        if (genpairs.first == nHeight)
            return true;
    return false;
}

CAmount getGenerationAmount(int nHeight)
{
    for (auto genpairs : creationPoints)
        if (genpairs.first == nHeight)
            return genpairs.second;
    return 0;
}

bool isGenerationRecipient(std::string recipient)
{
    const std::string testRecipient = "5b1c713017e9e6e019264b0e6e3e8c3a5e03a3db";
    if (recipient.find(testRecipient) != std::string::npos)
        return true;
    return false;
}
