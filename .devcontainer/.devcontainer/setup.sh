#!/bin/bash

echo "🎮 Setting up VIC-20 development environment..."

# Update package manager
sudo apt-get update

# Install ACME cross-assembler
echo "📦 Installing ACME assembler..."
sudo apt-get install -y acme

# Install additional tools
echo "📦 Installing development tools..."
sudo apt-get install -y wget curl unzip

# Create project structure
echo "📁 Creating project structure..."
mkdir -p src build tools docs examples

# Download VICE emulator (headless version for CLI)
echo "📦 Installing VICE emulator..."
sudo apt-get install -y vice

# Create sample VIC-20 program
echo "📝 Creating sample program..."
cat > src/hello.asm << 'EOF'
; Hello World for VIC-20
; Assembled with ACME

!to "build/hello.prg", cbm

; VIC-20 Constants
SCREEN_RAM = $1e00
COLOR_RAM = $9600
CHROUT = $ffd2

*= $1100                    ; Start at safe ML area

start:
    ; Clear screen
    lda #$93                ; Clear screen character
    jsr CHROUT
    
    ; Set up message pointer
    ldx #0
    
print_loop:
    lda message,x           ; Get character
    beq done                ; If zero, we're done
    jsr CHROUT              ; Print character
    inx
    bne print_loop          ; Continue until done
    
done:
    rts                     ; Return to BASIC

message:
    !text "HELLO VIC-20 FROM GITHUB CODESPACES!"
    !byte 13, 0             ; CR and null terminator
EOF

# Create build script
echo "🔧 Creating build tools..."
cat > tools/build.sh << 'EOF'
#!/bin/bash

echo "🔨 Building VIC-20 programs..."

# Create build directory if it doesn't exist
mkdir -p build

# Build all .asm files in src/
for asmfile in src/*.asm; do
    if [ -f "$asmfile" ]; then
        basename=$(basename "$asmfile" .asm)
        echo "   Assembling $basename..."
        
        acme -f cbm -o "build/${basename}.prg" "$asmfile"
        
        if [ $? -eq 0 ]; then
            echo "   ✅ Success: build/${basename}.prg"
        else
            echo "   ❌ Failed: $asmfile"
        fi
    fi
done

echo "🏁 Build complete!"
EOF

# Make build script executable
chmod +x tools/build.sh

# Create run script for VICE
cat > tools/run.sh << 'EOF'
#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: ./tools/run.sh <program_name>"
    echo "Example: ./tools/run.sh hello"
    exit 1
fi

PROGRAM="build/$1.prg"

if [ ! -f "$PROGRAM" ]; then
    echo "Program not found: $PROGRAM"
    echo "Run ./tools/build.sh first"
    exit 1
fi

echo "🎮 Running $PROGRAM in VIC-20 emulator..."
echo "   (Note: VICE runs in text mode in Codespaces)"
echo "   Use Ctrl+C to exit"

# Run in VIC-20 emulator (text mode)
xvic -console -autostart "$PROGRAM"
EOF

chmod +x tools/run.sh

# Create development reference
cat > docs/vic20-reference.md << 'EOF'
# VIC-20 Development Reference

## Memory Map
- $0000-$03FF: Zero page and stack
- $1000-$1DFF: RAM (safe for programs)
- $1E00-$1FE7: Screen RAM (22x23 characters)
- $8000-$8FFF: Character ROM
- $9000-$900F: VIC chip registers
- $9600-$97E7: Color RAM
- $C000-$DFFF: BASIC ROM

## Useful KERNAL Routines
- $FFD2: CHROUT - Output character
- $FFCF: CHRIN - Input character
- $FFE4: GETIN - Get key press

## VIC Chip Registers
- $9000: Horizontal position
- $9001: Vertical position  
- $9002: Columns displayed
- $9003: Rows displayed
- $900F: Screen/border color

## Colors
0=Black, 1=White, 2=Red, 3=Cyan, 4=Purple, 5=Green, 6=Blue, 7=Yellow
EOF

echo "✨ VIC-20 development environment ready!"
echo "   📁 Project structure created"
echo "   🔧 Build tools installed"
echo "   📝 Sample program created"
echo "   📚 Reference docs added"
echo ""
echo "🚀 Quick start:"
echo "   ./tools/build.sh     # Build all programs"
echo "   ./tools/run.sh hello # Run hello program"
EOF

4. Click "Commit changes"

## Step 4: Launch Your Codespace

1. Go to your repository main page
2. Click the green "Code" button
3. Click the "Codespaces" tab
4. Click "Create codespace on main"
5. Wait for the environment to set up (2-3 minutes)

## Step 5: Test Your Setup

Once your Codespace loads:

1. **Build the sample program:**
   ```bash
   ./tools/build.sh
