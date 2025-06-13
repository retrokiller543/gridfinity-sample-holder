# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an OpenSCAD project that generates customizable Gridfinity-compatible sample card holders. The system creates boxes with precisely calculated cutouts for sample cards (typically 76mm x 2.4mm) with three different layout algorithms.

## Core Architecture

### Main Components

- **`sample_card_holder.scad`**: Main entry point with customizable parameters and algorithm selection
- **`src/algorithms/grouped_v2.scad`**: The newest single-pass grouping algorithm (algorithm type 2)
- **`src/grouped_sample_cutouts.scad`**: Advanced grouping algorithm (algorithm type 1) 
- **`src/sample_cutouts.scad`**: Simple layout algorithm (algorithm type 0)
- **`src/gridfinity_box.scad`**: Gridfinity-compatible box generation
- **`src/grouping_layout_calculator.scad`**: Complex layout calculations for algorithm type 1

### Algorithm Types

The project implements three layout algorithms:
- **Type 0**: Simple Layout - basic row-based arrangement
- **Type 1**: Advanced Grouping - complex multi-pass algorithm with extensive calculations
- **Type 2**: Single-Pass Grouping V2 - simplified single-pass algorithm that maximizes groups

### Key Algorithm Principles (Type 2 - Grouped V2)

The newest algorithm follows these principles from `ALGORITHM_EXPLANATION.md`:
- **Orientation Detection**: Tests both sample orientations and chooses the one that fits more total samples
- **Axis-Aware Grouping**: Groups along the axis that can fit more samples (width vs depth)
- **Never Fail Principle**: Discards individual samples that don't fit, never entire groups
- **Sample Preservation**: Always renders the maximum number of samples possible within constraints

### Spacing Parameters

Three distinct spacing types must be used correctly:
- **`min_spacing`**: Spacing between individual samples within groups
- **`group_spacing`**: Spacing between groups within a row
- **`row_spacing`**: Spacing between rows (or columns when grouping along depth)

## Development Commands

### Testing with OpenSCAD

```bash
# Basic test with echo output
openscad sample_card_holder.scad --export-format=echo --render -o /tmp/test.echo -D "sh_algorithm_type=2"

# Test specific configuration
openscad sample_card_holder.scad --export-format=echo --render -o /tmp/test.echo \
  -D "sh_algorithm_type=2" \
  -D "sh_enable_grouping=true" \
  -D "sh_group_count=0" \
  -D "sh_samples_per_group=5" \
  -D "sh_box_width=4" \
  -D "sh_box_depth=1"

# Generate STL for 3D printing
openscad sample_card_holder.scad -o output.stl -D "sh_algorithm_type=2"
```

### Comprehensive Testing

```bash
# Run the full test suite (tests all permutations up to 10x10 containers)
python3 test_grouping_algorithm.py

# Results are stored in:
# - results/data/test_data_TIMESTAMP.json (raw data)
# - results/report/test_report_TIMESTAMP.md (analysis)
```

### Dependencies

Requires the `gridfinity-rebuilt-openscad` library to be available in the OpenSCAD library path or as a local directory.

## Common Development Patterns

### Algorithm Development

When working on layout algorithms:
1. Always include proper spacing calculations using the three spacing types
2. Test both sample orientations (normal and rotated)
3. Implement orientation-agnostic grouping (grouping direction should follow sample orientation)
4. Use echo statements for debugging calculations
5. Never discard entire groups - only individual samples that exceed boundaries

### Parameter Validation

The project uses OpenSCAD's customizer system with parameter ranges defined in comments:
- Box dimensions in gridfinity units with 0.5 increments
- Sample dimensions in millimeters
- Algorithm selection via enumerated types

### Testing Approach

The Python test suite generates comprehensive test matrices covering:
- All container sizes from 1x1 to 10x10 gridfinity units
- Various grouping strategies and parameters
- Both manual and auto-calculated group settings
- Success/failure analysis with detailed reporting