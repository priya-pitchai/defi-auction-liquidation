Hardhat Development Environment Setup Guide (Ubuntu + VS Code + Hardhat 3)
Building Your First Solidity Project
Audience
This guide is for:
    • Blockchain beginners 
    • Solidity developers moving from Remix to Hardhat 
    • Developers using Ubuntu/Linux 
    • Anyone setting up Hardhat 3 with VS Code 

# Prerequisites
Before installing Hardhat, ensure the following tools are available.
1. Install Node.js
Check whether Node.js is installed.
node -v
Expected output:
v22.x.x
If not installed:
sudo apt update
sudo apt install nodejs npm
Recommended: Install the latest LTS version using nvm for better version management.

2. Verify npm
npm -v
Expected output:
10.x.x

3. Install Visual Studio Code
Verify installation:
code --version

4. Recommended VS Code Extensions
Install:
    • Solidity 
    • Hardhat Solidity 
    • GitLens 
    • Error Lens 
    • Prettier 
    • ESLint 
Optional:
    • GitHub Copilot / Codex 

# Create the Project Folder
Avoid spaces in folder names.
❌ Avoid:
Auction Project
✅ Prefer:
auction-liquidation
Create the folder:
mkdir auction-liquidation
cd auction-liquidation
Verify:
pwd

Initialize npm
npm init -y
This creates:
package.json

Install Hardhat
npm install --save-dev hardhat

Initialize Hardhat
Do NOT run:
npx hardhat
If you do, you'll see:
Error HHE3: No Hardhat config file found.
This happens because the project hasn't been initialized yet.
Instead run:
npx hardhat --init

Hardhat 3 Initialization
Step 1
Choose:
Hardhat 3

# Step 2
When prompted:
Please provide either a relative or an absolute path
Type:
.
The single dot (.) means "initialize the project in the current directory."

# Step 3
Choose:
A minimal Hardhat project
Why?
A minimal project gives you:
    • Clean structure 
    • Fewer dependencies 
    • Easier learning 
    • Full control over added packages 

Step 4
Hardhat asks:
Hardhat only supports ESM projects.
Would you like to change package.json?
Choose:
Y
Hardhat 3 uses ESM (ECMAScript Modules).

Step 5
Hardhat installs:
typescript
@types/node
Choose:
Y
Wait for installation to complete.

Generated Project Structure
Initially:
auction-liquidation/
hardhat.config.ts
package.json
package-lock.json
README.md
tsconfig.json
node_modules/
Notice there are no contracts yet.

Create Project Structure
mkdir contracts
mkdir scripts
mkdir test
mkdir contracts/core
mkdir contracts/auction
mkdir contracts/interfaces
mkdir contracts/libraries
mkdir contracts/oracles
mkdir contracts/utils
Final structure:
auction-liquidation/
contracts/
│
├── auction/
├── core/
├── interfaces/
├── libraries/
├── oracles/
└── utils/
scripts/
test/
hardhat.config.ts
package.json
tsconfig.json

Verify the Installation
Compile:
npx hardhat compile
Expected:
Downloading solc 0.8.28
No contracts to compile
This means:
    • Hardhat installed correctly. 
    • Solidity compiler downloaded successfully. 
    • The environment is ready. 

Verify Hardhat Configuration
Default configuration:
import { defineConfig } from "hardhat/config";
export default defineConfig({
  solidity: {
    version: "0.8.28",
  },
});
This is sufficient for starting development.

Initialize Git
git init
Verify:
git status

Project Ready
At this point, you have:
    • Ubuntu 
    • Node.js 
    • npm 
    • Hardhat 3 
    • TypeScript 
    • Solidity Compiler 
    • Git Repository 
    • Project Structure 
Your development environment is now ready for Solidity development.

Common Beginner Mistakes (Real Issues We Encountered)
Mistake 1: Running npx hardhat
npx hardhat
Error:
HHE3: No Hardhat config file found
Reason: The project has not been initialized.
Fix:
npx hardhat --init

Mistake 2: Running Hardhat --init
Hardhat --init
Error:
command not found
Reason: Hardhat is not a global command.
Fix:
npx hardhat --init

Mistake 3: Opening the Wrong Folder in VS Code
Opening:
JUNE-2026-LEARNING
instead of:
auction-liquidation
can make it harder to focus on the project and may lead to confusion about where files belong.
Recommendation: Open the project folder directly.

Mistake 4: Using Folder Names with Spaces
Example:
Auction Project
Many CLI commands require quoting such paths.
Recommendation:
auction-liquidation

Mistake 5: Thinking "No contracts to compile" Is an Error
Output:
No contracts to compile
This is expected until you create your first Solidity file.

Mistake 6: Modifying .gitignore Unnecessarily
The Hardhat template already provides a suitable .gitignore.
Only add entries when you introduce new tools or build artifacts.

Mistake 7: Installing Every Plugin on Day One
Many tutorials install numerous plugins immediately.
Better approach: Install packages only when your project actually needs them. This keeps the setup simple and helps you understand the purpose of each dependency.

Mistake 8: Starting to Code Without Planning
A common beginner habit is to create MyToken.sol or another contract immediately after setup.
For production-style development, follow this sequence:
    1. Requirements 
    2. System Design 
    3. Architecture 
    4. Contract Design 
    5. Solidity Implementation 
    6. Unit Testing 
    7. Security Review 
    8. Deployment 

What's Next?
With the environment ready, the next phase is protocol engineering.
We'll move from tooling to design by creating:
    • System Architecture 
    • Contract Architecture 
    • Smart Contract Responsibilities 
    • Storage Design 
    • Event Model 
    • Error Model 
    • Function Signatures 
Only after the design is complete will we begin implementing Solidity contracts.

