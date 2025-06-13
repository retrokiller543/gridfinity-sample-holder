# Gridfinity Sample Holder Algorithm Explanation

## Sample Orientation Logic

For a box that is 42 x 168 x 21 mm (X x Y x Z):
- Sample cards are 76mm wide x 2.4mm thick
- Sample width (76mm) will NOT fit on X-axis (42mm) with its width
- Sample width (76mm) WILL fit on Y-axis (168mm) - can fit twice including minimum spacing
- Therefore samples must be oriented with their 2.4mm thickness along X-axis and 76mm width along Y-axis

## Row Calculation
- Calculate how many rows fit along Y-axis: 168mm / 76mm ≈ 2 rows (including spacing)
- Position rows as far out as possible within the Y dimension

## Samples Per Row Calculation  
- Calculate how many samples fit per row along X-axis: 42mm / 2.4mm ≈ 17 samples
- With minimum spacing between samples: ~10-11 samples per row
- This gives us the maximum samples that can physically fit in one row

## Grouping Logic
1. If user provides group_count: respect that number of groups per row
2. If group_count = 0 (auto): maximize the number of groups possible
3. Calculate samples_per_group based on total samples available and desired groups
4. If a group would exceed the row boundary, discard out-of-bounds samples (don't fail)
5. Always render the maximum amount of samples that can possibly fit

## Row Replication
- Once we have the grouping pattern for one row, copy it with Y-offsets for all other rows
- Each row gets the same grouping pattern, just shifted in the Y direction

## Key Principle
**Never fail the render** - if groups don't fit perfectly, discard individual samples but keep as many as possible. Always maximize the sample count within the physical constraints.

## Example Calculation
For 42 x 168 x 21 mm box:
- Samples oriented: 2.4mm (X) x 76mm (Y) 
- Rows possible: 168mm / 76mm ≈ 2 rows
- Samples per row: 42mm / 2.4mm ≈ 17 max, ~10-11 with spacing
- If user wants 3 groups per row: 3-4 samples per group
- If last group only fits 2 samples instead of 4: keep those 2, don't discard the whole group

## Axis Naming Convention
- X-axis = width direction (shorter dimension in typical gridfinity boxes)
- Y-axis = depth direction (longer dimension in typical gridfinity boxes)  
- Z-axis = height direction