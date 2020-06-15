// Copyright (c) 2020 The PACGlobal Developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#include <amount.h>
#include <validation.h>

//! created to move away the adhoc creation of PAC required on two occasions,
//! both to keep things neat and also to serve as a visible record.
//!
//! owing to the amount of time passed since each was generated, we simply
//! test for height and amount (via exception), rather than matching script/payee etc for
//! speed during initial sync/validation.

typedef std::map<int, CAmount> GeneratedFunds;

const GeneratedFunds creationPoints = {
     { 362250, 700000000 * COIN  },
     { 387989, 1000000000 * COIN },
};

bool isGenerationBlock(int nHeight)
{
	for (auto genpairs : creationPoints)
	    if (genpairs.first == nHeight)
                return true;
        return false;
}
