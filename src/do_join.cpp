#include <fstream>
#include <string>
#include <regex>
#include <filesystem>
#include <vector>
#include <boost/algorithm/string.hpp>

using namespace std;
namespace fs = filesystem;

bool compare_keys(const vector<string>& v1, const vector<string>& v2)
{
  for ( int i=0; i < 4; i++ )
    if ( v1[i] != v2[i] )
      return false;
  return true;
}

vector<string> tokenize_line(const string& line, const string& delim)
{
  vector<string> fields;
  boost::split(fields, line, boost::is_any_of(delim));
  return fields;
}

int main(int argc, char *argv[])
{
  fs::path p = argv[1];
  string stem = p.stem().string();

  // Open the files
  ifstream infile(p);
  ifstream work(p.parent_path() / "out.csv");
  ofstream temp(p.parent_path() / "tmp.csv");

  // Accession number
  regex re("^sorted_(.*?)_.*");
  smatch sm;
  regex_match(stem, sm, re);

  // Dim strings
  string line, candidate;

  // Header
  getline(work, line);
  temp << line << "," << sm[1] << "\n";

  // Preload first line from infile
  getline(infile, candidate);
  vector<string> candidate_tokenized = tokenize_line(candidate, "\t");

  // Loop over working file
  while ( getline(work, line) )
  {
    temp << line << ",";
    vector<string> line_tokenized = tokenize_line(line, ",");

    if ( compare_keys(line_tokenized, candidate_tokenized) )
    {
      temp << candidate_tokenized[6];
      getline(infile, candidate);
      candidate_tokenized = tokenize_line(candidate, "\t");
    }

    temp << "\n";
  }

  // Close file connections
  temp.close();
  work.close();
  infile.close();

  // Overwrite old working file
  fs::rename(p.parent_path() / "tmp.csv",
             p.parent_path() / "out.csv");

  return 0;
}

