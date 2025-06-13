#!/usr/bin/env python3

import subprocess
import json
import re
import os
from datetime import datetime
import itertools
import asyncio
from tqdm.asyncio import tqdm

class GroupingTestSuite:
    def __init__(self):
        self.test_results = []
        self.failed_tests = []
        self.passed_tests = []
        
    async def run_openscad_test(self, test_config, semaphore):
        """Asynchronously run OpenSCAD with given configuration via command line parameters"""
        
        async with semaphore:
            # Create unique output file for this test
            output_file = f'/tmp/openscad_test_{hash(frozenset(test_config.items()))}.echo'
            
            # Build OpenSCAD command with parameters
            cmd = [
                'openscad', 'sample_card_holder.scad',
                '--export-format=echo', '--render', 
                '-o', output_file,
                '-D', f'sh_box_width={test_config["box_width"]}',
                '-D', f'sh_box_depth={test_config["box_depth"]}', 
                '-D', f'sh_enable_grouping={"true" if test_config["enable_grouping"] else "false"}',
                '-D', f'sh_group_count={test_config["group_count"]}',
                '-D', f'sh_samples_per_group={test_config["samples_per_group"]}',
                '-D', f'sh_group_spacing={test_config["group_spacing"]}'
            ]
            
            # Create the subprocess
            proc = await asyncio.create_subprocess_exec(
                *cmd,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )

            try:
                # Wait for the process to complete with a timeout
                stdout_bytes, stderr_bytes = await asyncio.wait_for(proc.communicate(), timeout=60)
                
                output_content = ""
                # If the process succeeded, read the output file
                if proc.returncode == 0 and os.path.exists(output_file):
                    with open(output_file, 'r') as f:
                        output_content = f.read()
                    os.remove(output_file)

                return {
                    'stdout': output_content,
                    'stderr': stderr_bytes.decode('utf-8', errors='ignore'),
                    'returncode': proc.returncode,
                    'success': proc.returncode == 0,
                    'command': ' '.join(cmd)
                }
            except asyncio.TimeoutError:
                proc.kill()
                await proc.wait()
                return {
                    'stdout': '',
                    'stderr': 'TIMEOUT',
                    'returncode': -1,
                    'success': False,
                    'command': ' '.join(cmd)
                }
            except Exception as e:
                return {
                    'stdout': '',
                    'stderr': str(e),
                    'returncode': -2,
                    'success': False,
                    'command': ' '.join(cmd)
                }

    def parse_openscad_output(self, output):
        """Parse OpenSCAD echo output to extract key metrics"""
        lines = output.split('\n')
        
        metrics = {
            'interior_space': None,
            'sample_size': None,
            'grouping_mode': None,
            'group_count': None,
            'samples_per_group': None,
            'group_spacing': None,
            'generated_rows': 0,
            'total_samples': 0,
            'rows_info': [],
            'errors': [],
            'assertions': [],
            'algorithm_type': None
        }
        
        for line in lines:
            line = line.strip()
            
            # Extract basic info from ECHO statements
            if 'Interior space:' in line:
                match = re.search(r'Interior space: ([\d.]+) x ([\d.]+) mm', line)
                if match:
                    metrics['interior_space'] = (float(match.group(1)), float(match.group(2)))
            
            elif 'Sample size:' in line:
                match = re.search(r'Sample size: ([\d.]+) x ([\d.]+) mm', line)
                if match:
                    metrics['sample_size'] = (float(match.group(1)), float(match.group(2)))
            
            elif 'Algorithm:' in line:
                if 'Advanced Grouping' in line:
                    metrics['algorithm_type'] = 'advanced'
                elif 'Simple Layout' in line:
                    metrics['algorithm_type'] = 'simple'
            
            elif 'Grouping mode:' in line:
                metrics['grouping_mode'] = 'enabled' if 'enabled' in line else 'disabled'
            
            elif 'Group count:' in line:
                match = re.search(r'Group count: (\w+)', line)
                if match:
                    metrics['group_count'] = match.group(1)
            
            elif 'Samples per group:' in line:
                match = re.search(r'Samples per group: (\w+)', line)
                if match:
                    metrics['samples_per_group'] = match.group(1)
            
            elif 'Group spacing:' in line:
                match = re.search(r'Group spacing: ([\d.]+)mm', line)
                if match:
                    metrics['group_spacing'] = float(match.group(1))
            
            elif 'Generated' in line and 'rows' in line:
                match = re.search(r'Generated (\d+) rows', line)
                if match:
                    metrics['generated_rows'] = int(match.group(1))
            
            elif 'Total samples:' in line:
                match = re.search(r'Total samples: (\d+)', line)
                if match:
                    metrics['total_samples'] = int(match.group(1))
            
            elif line.startswith('ECHO: "Row'):
                # Parse row info: "Row 1 (y=0): 42 samples, normal orientation"
                match = re.search(r'Row (\d+) \(y=([\d.-]+)\): (\d+) samples, (\w+) orientation', line)
                if match:
                    row_info = {
                        'row_num': int(match.group(1)),
                        'y_pos': float(match.group(2)),
                        'samples': int(match.group(3)),
                        'orientation': match.group(4)
                    }
                    metrics['rows_info'].append(row_info)
            
            elif 'Groups:' in line:
                # Parse groups info: "  Groups: [6, 6, 6, 6, 6, 6, 7]"
                match = re.search(r'Groups: \[([\d,\s]+)\]', line)
                if match and metrics['rows_info']:
                    groups_str = match.group(1)
                    groups = [int(x.strip()) for x in groups_str.split(',') if x.strip()]
                    metrics['rows_info'][-1]['groups'] = groups
            
            elif 'ERROR:' in line or 'Assertion' in line:
                metrics['errors'].append(line)
            
            elif 'TRACE:' in line:
                metrics['assertions'].append(line)
        
        return metrics

    def validate_test_result(self, config, metrics):
        """Validate test results and identify issues"""
        issues = []
        
        # Check if we're using the right algorithm
        if config['enable_grouping'] and metrics['algorithm_type'] != 'advanced':
            issues.append("Should use advanced algorithm when grouping enabled")
        
        # Check if grouping is working when enabled
        if config['enable_grouping'] and metrics['generated_rows'] > 0:
            # Check if groups were actually created
            has_multiple_groups = False
            total_groups_found = 0
            
            for row in metrics['rows_info']:
                if 'groups' in row:
                    total_groups_found += len(row['groups'])
                    if len(row['groups']) > 1:
                        has_multiple_groups = True
            
            # If we requested specific group settings, validate them
            if config['samples_per_group'] > 0 and config['samples_per_group'] < 15:
                if not has_multiple_groups and total_groups_found == 0:
                    issues.append(f"No groups created despite grouping enabled with {config['samples_per_group']} samples/group")
            
            # Check group count parameter
            if config['group_count'] > 0 and total_groups_found == 0:
                 if metrics['total_samples'] > 0: # Only an issue if samples were expected
                    issues.append(f"Group count parameter {config['group_count']} ignored - no groups created")
        
        # Check for assertion failures from OpenSCAD
        if metrics['errors']:
            issues.append(f"Assertion failures: {len(metrics['errors'])} errors")
        
        # Check for reasonable sample counts
        if metrics['total_samples'] > 500: # Increased limit for larger containers
            issues.append(f"Unrealistic sample count: {metrics['total_samples']}")
        elif metrics['total_samples'] == 0 and config['enable_grouping'] and config['box_width'] > 1 and config['box_depth'] > 1:
            # Only flag zero samples if the container is not trivially small
            issues.append("Zero samples generated with grouping enabled on a non-trivial container")
        
        # Check if samples per group setting was respected
        if config['enable_grouping'] and config['samples_per_group'] > 0:
            for row in metrics['rows_info']:
                if 'groups' in row:
                    for group_size in row['groups']:
                        # Allow a small tolerance for how the algorithm distributes remainders
                        if group_size > config['samples_per_group'] + 1:
                            issues.append(f"Group size {group_size} exceeds requested {config['samples_per_group']}")
        
        return issues

    def generate_test_configurations(self):
        """Generate comprehensive test configurations for all permutations up to specified limits."""
        
        # Container sizes to test: all permutations from 1x1 to 10x10
        container_sizes = list(itertools.product(range(1, 11), range(1, 11)))
        
        # Define a curated list of settings to test to keep the total number of tests manageable
        group_settings = []
        
        # 1. Baseline: Grouping disabled
        group_settings.append(
            {'enable_grouping': False, 'group_count': 0, 'samples_per_group': 0, 'group_spacing': 3.0}
        )
        
        # 2. Grouping enabled: Test various strategies
        group_counts_to_test = [2, 5, 10, 15, 20]  # Key values for group count up to 20
        samples_per_group_to_test = [2, 5, 8, 10, 15, 25, 50]  # Key values for samples per group up to 50
        spacings_to_test = [1.0, 5.0]  # Test different spacing values

        # a. Auto-grouping (where the algorithm decides everything)
        group_settings.append(
            {'enable_grouping': True, 'group_count': 0, 'samples_per_group': 0, 'group_spacing': 3.0}
        )

        # b. Test by varying 'group_count'
        for count in group_counts_to_test:
            group_settings.append(
                {'enable_grouping': True, 'group_count': count, 'samples_per_group': 0, 'group_spacing': 3.0}
            )
            
        # c. Test by varying 'samples_per_group' and 'group_spacing'
        for samples in samples_per_group_to_test:
            for spacing in spacings_to_test:
                 group_settings.append(
                    {'enable_grouping': True, 'group_count': 0, 'samples_per_group': samples, 'group_spacing': spacing}
                )

        # Combine container sizes with all defined group settings
        configs = []
        for (width, depth), group_setting in itertools.product(container_sizes, group_settings):
            config = {
                'box_width': width,
                'box_depth': depth,
                **group_setting
            }
            configs.append(config)
        
        # Remove any potential duplicates
        unique_configs = []
        seen = set()
        for config in configs:
            # A frozenset of items can be added to a set to check for uniqueness
            config_tuple = frozenset(config.items())
            if config_tuple not in seen:
                unique_configs.append(config)
                seen.add(config_tuple)
        
        return unique_configs
    
    async def process_single_config(self, config, semaphore):
        """A wrapper to run a single test configuration and process its results."""
        # This function no longer prints anything, it just returns the results.
        openscad_result = await self.run_openscad_test(config, semaphore)
        
        if openscad_result['success']:
            metrics = self.parse_openscad_output(openscad_result['stdout'])
            issues = self.validate_test_result(config, metrics)
            
            return {
                'config': config, 'metrics': metrics, 'issues': issues,
                'success': len(issues) == 0, 'openscad_output': openscad_result['stdout'],
                'command': openscad_result['command']
            }
        else:
            return {
                'config': config, 'metrics': {}, 'issues': [f"OpenSCAD crashed: {openscad_result['stderr']}"],
                'success': False, 'openscad_output': openscad_result['stderr'],
                'command': openscad_result['command']
            }

    async def run_test_suite(self):
        """Run the complete test suite in parallel with a tqdm progress bar."""
        print("🚀 Starting Gridfinity Grouping Algorithm Test Suite (Parallel Mode)")
        print("=" * 70)
        
        configs = self.generate_test_configurations()
        print(f"Generated {len(configs)} test configurations")
        
        # Use a semaphore to limit the number of concurrent processes
        concurrency_limit = os.cpu_count() or 4
        print(f"Running up to {concurrency_limit} tests in parallel...")
        print("=" * 70)
        semaphore = asyncio.Semaphore(concurrency_limit)
        
        # Create a task for each test configuration
        tasks = [self.process_single_config(config, semaphore) for config in configs]
        
        # Initialize counters for the progress bar
        passed_count = 0
        failed_count = 0

        # Use tqdm to create and manage the progress bar
        pbar = tqdm(total=len(configs), desc="Running tests", unit="test")
        
        for future in asyncio.as_completed(tasks):
            result = await future
            
            self.test_results.append(result)
            if result['success']:
                passed_count += 1
                self.passed_tests.append(result)
            else:
                failed_count += 1
                self.failed_tests.append(result)
            
            # Update the progress bar's postfix with live stats
            success_ratio = (passed_count / (passed_count + failed_count)) * 100 if (passed_count + failed_count) > 0 else 0
            pbar.set_postfix({
                'passed': f"{passed_count} ✅",
                'failed': f"{failed_count} ❌",
                'ratio': f"{success_ratio:.1f}%"
            })
            
            pbar.update(1)
        
        pbar.close()

    def generate_step_files(self):
        """Generate STEP files for failed configurations to visualize issues"""
        if not self.failed_tests:
            return
        
        print("\n📦 Generating STEP files for failed configurations...")
        step_dir = f"failed_configs_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        os.makedirs(step_dir, exist_ok=True)
        
        # Limit to the first 10 failures to avoid creating too many files
        for i, test in enumerate(self.failed_tests[:10]):
            # Skip crashes or tests that weren't meant to produce groups anyway
            if not test['config']['enable_grouping'] or 'crashed' in test['issues'][0]:
                continue
            
            config = test['config']
            filename = f"w{config['box_width']}_d{config['box_depth']}_gc{config['group_count']}_spg{config['samples_per_group']}.step"
            filepath = os.path.join(step_dir, filename)
            
            cmd = [
                'openscad', 'sample_card_holder.scad',
                '-o', filepath,
                '-D', f'sh_box_width={config["box_width"]}',
                '-D', f'sh_box_depth={config["box_depth"]}', 
                '-D', f'sh_enable_grouping={"true" if config["enable_grouping"] else "false"}',
                '-D', f'sh_group_count={config["group_count"]}',
                '-D', f'sh_samples_per_group={config["samples_per_group"]}',
                '-D', f'sh_group_spacing={config["group_spacing"]}'
            ]
            
            try:
                # Use subprocess.run here since this part is not performance-critical
                result = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
                if result.returncode == 0:
                    print(f"    ✅ Generated: {filename}")
                else:
                    print(f"    ❌ Failed to generate {filename}: {result.stderr[:50]}")
            except Exception as e:
                print(f"    ❌ Error generating {filename}: {str(e)}")
        
        print(f"\nSTEP files for review saved to: {step_dir}/")

    def generate_report(self):
        """Generate detailed test report in Markdown and JSON formats"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        results_dir = 'results'
        reports_dir = f'{results_dir}/report'
        data_dir = f'{results_dir}/data'
        os.makedirs(reports_dir, exist_ok=True)
        os.makedirs(data_dir, exist_ok=True)

        # Generate summary report in Markdown
        report_file = f'{reports_dir}/test_report_{timestamp}.md'
        with open(report_file, 'w') as f:
            f.write("# Gridfinity Grouping Algorithm Test Report\n\n")
            f.write(f"**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
            f.write(f"## Summary\n\n")
            f.write(f"- **Total Tests:** {len(self.test_results)}\n")
            f.write(f"- **Passed:** {len(self.passed_tests)} ✅\n")
            f.write(f"- **Failed:** {len(self.failed_tests)} ❌\n")
            if not self.test_results:
                f.write("- **Success Rate:** N/A\n\n")
            else:
                f.write(f"- **Success Rate:** {len(self.passed_tests)/len(self.test_results)*100:.1f}%\n\n")
            
            # Key issues analysis
            f.write("## Key Issues Found\n\n")
            
            issue_counts = {}
            for test in self.failed_tests:
                for issue in test['issues']:
                    # Generalize issue keys for better grouping
                    key = issue.split(':')[0] if ':' in issue else issue
                    issue_counts[key] = issue_counts.get(key, 0) + 1
            
            if not issue_counts:
                f.write("No major issues found. Congratulations!\n\n")
            else:
                for issue, count in sorted(issue_counts.items(), key=lambda x: x[1], reverse=True):
                    f.write(f"- **{issue}**: {count} occurrences\n")
            
            f.write("\n")
            
            # Detailed breakdown by container size and grouping strategy
            f.write("### Success Rate by Configuration\n\n")
            f.write("| Container Size | Grouping Off | Small Groups (<8) | Large Groups (≥8) |\n")
            f.write("|----------------|--------------|-------------------|-------------------|\n")
            
            # Dynamically discover all container sizes from the test results
            container_sizes = sorted(list(set([(t['config']['box_width'], t['config']['box_depth']) for t in self.test_results])))

            for width, depth in container_sizes:
                size_tests = [t for t in self.test_results if t['config']['box_width'] == width and t['config']['box_depth'] == depth]
                
                no_grouping = [t for t in size_tests if not t['config']['enable_grouping']]
                small_groups = [t for t in size_tests if t['config']['enable_grouping'] and t['config']['samples_per_group'] > 0 and t['config']['samples_per_group'] < 8]
                large_groups = [t for t in size_tests if t['config']['enable_grouping'] and t['config']['samples_per_group'] >= 8]
                
                def success_rate(tests):
                    if not tests: return "N/A"
                    passed = len([t for t in tests if t['success']])
                    return f"{passed}/{len(tests)} ({passed/len(tests)*100:.0f}%)"
                
                f.write(f"| {width}x{depth} | {success_rate(no_grouping)} | {success_rate(small_groups)} | {success_rate(large_groups)} |\n")
        
        # Generate detailed JSON data for further analysis
        data_file = f'{data_dir}/test_data_{timestamp}.json'
        with open(data_file, 'w') as f:
            json.dump(self.test_results, f, indent=2)
        
        print(f"\n📊 Reports generated:")
        print(f"  - {report_file}")
        print(f"  - {data_file}")
        
        return report_file

if __name__ == "__main__":
    suite = GroupingTestSuite()
    # Run the entire test suite using asyncio
    asyncio.run(suite.run_test_suite())
    
    report_file = ""
    if suite.test_results:
        # The report generation happens after all async tasks are complete
        report_file = suite.generate_report()

    print(f"\n🏁 Test Summary:")
    print(f"  Passed: {len(suite.passed_tests)}")
    print(f"  Failed: {len(suite.failed_tests)}")
    if suite.test_results:
        print(f"  Success Rate: {len(suite.passed_tests)/len(suite.test_results)*100:.1f}%")
    
    if suite.failed_tests:
        print(f"\n🤔 Next steps:")
        print(f"  1. Review the detailed markdown report: {report_file}")
        print(f"  2. Examine the raw data for patterns: {os.path.abspath('results/data')}")
        print(f"  3. Focus on configurations with the lowest success rates.")
        
        # Prompt to generate STEP files for visual debugging
        generate_steps = input("\nGenerate STEP files for a sample of failed configs? (y/N): ")
        if generate_steps.lower() == 'y':
            suite.generate_step_files()

