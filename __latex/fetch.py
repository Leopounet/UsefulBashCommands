from __future__ import annotations
import glob, os
import shutil
import unidecode

from typing import List, Set

###############################################################################
############################## CLASS ##########################################
###############################################################################

class SpecialLabel:

    def __init__(self, gen_type, spe_type, name):
        self.gen_type : str = gen_type
        self.spe_type : str = spe_type
        self.name : str = name
        self.id : str = str(hex(hash(gen_type + spe_type + name))[2:])

    def __str__(self):
        return f"{self.gen_type}:{self.spe_type}:{self.name}"

###############################################################################
############################## VARIABLES ######################################
###############################################################################

build_dir = "build_py_tex"
build_dir_exists = glob.glob(build_dir) != []

sum_dir = "summaries"
sum_file = "summaries.tex"

spl_file = "speciallabel.tex"

exclude_files = {
    "bib.tex",
    "packages.tex",
    sum_file,
    spl_file,
    "ref.bib",
    "macro.tex"
}

tex_files = set(glob.glob("*.tex"))
summaries_tex_files = set(glob.glob(f"{sum_dir}/*.tex"))
tex_files = tex_files.difference(exclude_files)

special_label_key = "\speciallabel"

shortnames_to_names = {
    "def": "Définitions",
    "fun": "Fonctions",
    "the": "Théorèmes",
    "lst": "Listings",
    "aut": "Automates",
    "abs": "Interprétation abstraite",
    "mc": "Model Checking",
    "inv": "Invariants",
    "log": "Logique",
    "fau": "Fautes"
}

###############################################################################
############################## FUNCTIONS ######################################
###############################################################################

# returns the normalized version of the given string
def normalize(string : str):
    new_string = ""
    for c in string:
        if c.isalnum():
            new_string += c
        if c in "./":
            new_string += c
    return unidecode.unidecode(new_string)


# returns the index of the closing bracket
def get_closing_index(line : str):
    if line.startswith("{"): line = line[1:]
    count = 1
    index = 0
    for c in line:
        if c == "{": count += 1
        if c == "}": count -= 1
        if count == 0: return index + 1
        index += 1
    return -1

# extracts the special label string
def extract_spl(line : str):
    # extract the actual name
    close_index = get_closing_index(line)
    lines = line[1:close_index].split(":")

    # check that there are indeed enough fields
    if len(lines) != 3:
        print("Badly formatted speciallabel: " + line)
        return None

    line_without_spl = line[(close_index + 1):]

    # return the fields gen_type:spe_type:name
    # gen_type -> general type, is it a definition, a function, ...
    # spe_type -> specific type, is it linked to automaton, abstract interpretation, ...
    # name -> name of the label
    gen_type, spe_type, name = lines[0], lines[1], lines[2]
    return SpecialLabel(gen_type, spe_type, name), line_without_spl

# creates a copy of the original tex file but all "speciallabel" are 
# replaced by labels
def copy_without_labels(source, dest):

    # the list of retrieved labels
    labels = []

    # run through the source file to find all "speciallabel"
    for line in source:
        
        # split whenever a speciallabel is found
        lines : list = line.split(special_label_key)
        unaltered_lines = lines.copy()
        lines = lines[1:] if len(lines) > 1 else []

        # for each special label
        for index, line in enumerate(lines):
            spl, new_line = extract_spl(line)
            unaltered_lines[index + 1] = "\\label{" + spl.id + "}" + new_line
            labels.append(spl)
        dest.write("".join(unaltered_lines))
    
    return labels

# sorts all the labels
def sort_labels(labels : List[SpecialLabel]):

    # i use a list instead of a dict bc it makes some computations
    # faster and easier, though it makes the next bit a bit intricate

    # creates different lists for different arguments
    # there are two levels : 
    # [[[], [], []...], [[], [], []...]]
    # first level is the general type
    # second level is the specific type
    # then the value is acquired
    new_labels = []

    # keeping track of seen labels depending on their depth
    seen = {}

    # parse all labels
    for label in labels:

        # ease of reading
        g, s = label.gen_type, label.spe_type

        # index at which the current label will be stored
        outer_index, inner_index = -1, -1

        # has this generic type been seen yet? if yes get its 
        # outer index
        if g in seen:
            outer_index, seen_spe = seen[g]

            if s in seen_spe:
                inner_index = seen_spe[s]

            else:
                new_labels[outer_index].append([])
                seen_spe[s] = len(new_labels[outer_index]) - 1
                inner_index = seen_spe[s]

        else:
            new_labels.append([])
            seen[g] = (len(new_labels) - 1, {s: 0})
            outer_index, _ = seen[g]
            new_labels[outer_index].append([])
            inner_index = 0

        new_labels[outer_index][inner_index].append(label)
    
    for gen in new_labels:
        for spe in gen:
            spe.sort(key=lambda x: x.name)

    return new_labels


# handles all the retrieved labels so that they are stored and linked correctly 
# in a separate file
def handle_labels(labels : List[List[List[SpecialLabel]]]):

    # this is the file in which all the labels will be stored
    with open(spl_file, "w") as file:

        file.write("\\section{Glossaires}\n\n")

        for gen in labels:
            first_gen = True
            for spe in gen:
                first_spe = True
                for label in spe:
                    
                    if first_gen:
                        file.write("\\subsection{" + shortnames_to_names[label.gen_type] + "}\n\n")
                        first_gen = False

                    if first_spe:
                        file.write("\\subsubsection{" + shortnames_to_names[label.spe_type] + "}\n\n")
                        first_spe = False

                    file.write("\\noindent \\par \\hyperref[" + label.id + "]{" + label.name + "} \\dotfill \\pageref{" + label.id + "}\n")

            file.write("\\newpage")

def handle_summaries(files : Set[str]):
    files = list(files)
    files.sort()
    with open(sum_file, "w") as dest:
        for file in files: 
            dest.write("\\input{\"" + file + "\"}\n")        

###############################################################################
############################## SCRIPT #########################################
###############################################################################

# check if this was the primary file called
if __name__ == "__main__":

    # print(tex_files, build_dir_exists)

    # creates a build dir if it does not exist yet
    if build_dir_exists:
        shutil.rmtree(build_dir)

    os.mkdir(build_dir)
    os.mkdir(build_dir + "/" + sum_dir)

    # parse all files 
    labels = []
    for tex_file in tex_files.union(summaries_tex_files):
        with open(tex_file, "r") as src:
            with open(build_dir + "/" + tex_file, "w") as dest:
                labels += copy_without_labels(src, dest)

    handle_labels(sort_labels(labels))
    handle_summaries(summaries_tex_files)

    # copy all files that are excluded
    for tex_file in exclude_files:
        shutil.copy(tex_file, build_dir + "/" + tex_file)