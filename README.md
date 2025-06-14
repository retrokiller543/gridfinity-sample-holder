# Gridfinity FFS Sample Card Holder

A highly customizable OpenSCAD-based sample card holder system designed for the Gridfinity ecosystem. This project generates 3D-printable boxes with precise cutouts for sample cards (typically 76mm x 2.4mm) using three different intelligent layout algorithms.

![Sample Holder Examples](images/advanced_algorithm.png)

## Features

- **Three Layout Algorithms**: Choose from simple, advanced grouping, or single-pass grouping algorithms
- **Gridfinity Compatible**: Full compatibility with the Gridfinity modular storage system
- **Intelligent Orientation**: Automatically detects optimal sample orientation for maximum capacity
- **Flexible Grouping**: Support for manual or automatic group sizing with intelligent spacing
- **Label System**: Integrated magnetic label support for easy organization
- **Comprehensive Testing**: Extensive test suite covering all container sizes and configurations

## Quick Start

### Prerequisites

1. **OpenSCAD** (version 2021.01 or later)
2. **gridfinity-rebuilt-openscad library** - Available in OpenSCAD library manager or from [GitHub](https://github.com/kennetek/gridfinity-rebuilt-openscad)

### Basic Usage

1. Open `sample_card_holder.scad` in OpenSCAD
2. Customize parameters using the built-in customizer panel
3. Press F5 to preview or F6 to render
4. Export as STL for 3D printing

### Command Line Usage

```bash
# Basic render with default settings
openscad sample_card_holder.scad -o output.stl

# Custom configuration with grouping algorithm
openscad sample_card_holder.scad -o custom_holder.stl \
  -D "sh_algorithm_type=2" \
  -D "sh_box_width=4" \
  -D "sh_box_depth=2" \
  -D "sh_enable_grouping=true" \
  -D "sh_samples_per_group=5"

# Test configuration with echo output
openscad sample_card_holder.scad --export-format=echo --render -o /tmp/test.echo \
  -D "sh_algorithm_type=2"
```

## Layout Algorithms

### Algorithm Type 0: Simple Layout
- Basic row-based arrangement
- Minimal complexity, reliable results
- Best for straightforward requirements

### Algorithm Type 1: Advanced Grouping
- Multi-pass algorithm with complex calculations
- Handles various grouping scenarios
- Extensive spacing and layout optimization

### Algorithm Type 2: Single-Pass Grouping V2 (Recommended)
- Newest and most efficient algorithm
- **Orientation Detection**: Tests both sample orientations and chooses optimal layout
- **Axis-Aware Grouping**: Groups along the axis that maximizes sample count
- **Never Fail Principle**: Discards individual samples that don't fit, never entire groups
- **Sample Preservation**: Always renders maximum possible samples within constraints

## Parameters

### Box Dimensions
- `sh_box_width`: Width in gridfinity units (42mm each) [1:0.5:10]
- `sh_box_depth`: Depth in gridfinity units [1:0.5:10]
- `sh_box_height`: Total height in millimeters [15:0.2:50]

### Sample Dimensions
- `sh_sample_width`: Width of sample cards in mm [20:1:300]
- `sh_sample_height`: Height for reference [10:1:25]
- `sh_sample_thickness`: Thickness in mm [1:0.1:10]

### Grouping Options
- `sh_enable_grouping`: Enable grouping features
- `sh_group_count`: Number of groups (0 = auto-calculate)
- `sh_samples_per_group`: Desired samples per group
- `sh_group_spacing`: Spacing between groups
- `sh_min_spacing`: Spacing between individual samples

## Project Structure

```
gridfinity-ffs-holder/
├── sample_card_holder.scad      # Main entry point
├── src/
│   ├── algorithms/
│   │   └── grouped_v2.scad      # Latest grouping algorithm
│   ├── gridfinity_box.scad      # Gridfinity base generation
│   ├── sample_cutouts.scad      # Simple layout algorithm
│   ├── grouped_sample_cutouts.scad  # Advanced grouping
│   ├── label_system.scad        # Magnetic label support
│   └── layout_calculator.scad   # Layout calculations
├── test_grouping_algorithm.py   # Comprehensive test suite
├── images/                      # Example images
├── results/                     # Test results and reports
└── ALGORITHM_EXPLANATION.md     # Detailed algorithm documentation
```

## Testing

### Comprehensive Test Suite

Run the full test suite to validate all algorithms across different configurations:

```bash
python3 test_grouping_algorithm.py
```

This tests all permutations up to 10x10 containers and generates:
- **Raw data**: `results/data/test_data_TIMESTAMP.json`
- **Analysis report**: `results/report/test_report_TIMESTAMP.md`

### Manual Testing

```bash
# Test specific algorithm with debug output
openscad sample_card_holder.scad --export-format=echo --render -o /tmp/debug.echo \
  -D "sh_algorithm_type=2" \
  -D "sh_box_width=4" \
  -D "sh_box_depth=1" \
  -D "sh_enable_grouping=true"
```

## Algorithm Principles (Type 2)

The newest algorithm follows these key principles:

1. **Orientation Detection**: Tests both sample orientations (normal and rotated) to determine which fits more samples
2. **Axis-Aware Grouping**: Groups along the axis that can accommodate more samples (width vs depth)
3. **Never Fail Principle**: If individual samples don't fit within boundaries, they are discarded rather than failing the entire group
4. **Sample Preservation**: Always renders the maximum number of samples possible within physical constraints

### Spacing System

Three distinct spacing types ensure proper fitment:
- **`min_spacing`**: Between individual samples within groups
- **`group_spacing`**: Between groups within a row
- **`row_spacing`**: Between rows (or columns when grouping along depth)

## Examples

### Basic Sample Holder (1x4 Gridfinity Units)
```scad
sh_box_width = 1;
sh_box_depth = 4;
sh_algorithm_type = 2;
sh_enable_grouping = true;
sh_samples_per_group = 5;
```

### Large Multi-Group Holder (4x2 Gridfinity Units)
```scad
sh_box_width = 4;
sh_box_depth = 2;
sh_algorithm_type = 2;
sh_enable_grouping = true;
sh_group_count = 0; // Auto-calculate optimal groups
```

### Custom Sample Dimensions
```scad
sh_sample_width = 85;      // Custom width
sh_sample_thickness = 3.0; // Thicker samples
sh_algorithm_type = 2;
```

## Label System

The project includes magnetic label support for easy organization:
- Magnetic base compatibility
- Customizable label dimensions
- Integrated with main holder design

## Development

### Contributing

When working on layout algorithms:
1. Always include proper spacing calculations using the three spacing types
2. Test both sample orientations (normal and rotated)
3. Implement orientation-agnostic grouping
4. Use echo statements for debugging calculations
5. Never discard entire groups - only individual samples that exceed boundaries

### Dependencies

- **gridfinity-rebuilt-openscad**: Core gridfinity library for base generation
- **Python 3.x**: For running the test suite (optional)
- **tqdm**: For progress bars in testing (install via `pip install tqdm`)

## License

This project is designed for the maker community. Feel free to use, modify, and distribute according to your needs.

## Troubleshooting

### Common Issues

1. **"Cannot find gridfinity library"**
   - Install gridfinity-rebuilt-openscad via OpenSCAD's library manager
   - Or clone it locally and ensure it's in OpenSCAD's library path

2. **Samples don't fit in container**
   - Check sample dimensions vs container size
   - Try algorithm type 2 for automatic orientation detection
   - Reduce group count or samples per group

3. **Render fails or produces empty results**
   - Verify all parameters are within valid ranges
   - Check OpenSCAD console for error messages
   - Try simpler algorithm (type 0) first

### Debug Mode

Enable detailed debug output by setting echo statements in the algorithm files. Look for console output during rendering to understand layout calculations.

## Support

For issues, suggestions, or contributions, please refer to the project repository or contact the maintainer.