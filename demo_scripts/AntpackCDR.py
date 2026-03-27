import os
import antpack
import biotite
import biotite.structure as struc   
import biotite.sequence as seq
import pandas as pd
from antpack import SingleChainAnnotator
from StrucTools import *

def extract_binder_seqs(pdb_folder: str) -> dict:
    """ Given a folder containing PDB files, extract the binder sequences from each PDB file and return a dictionary of PDB IDs and corresponding sequences 
    """
    binder_seqs = {}
    for file in os.listdir(pdb_folder):
        if file.endswith(".pdb"):
            pdb_path = os.path.join(pdb_folder, file)
            pdb_id = file.split(".")[0]
            atom_array_complex = extract_atom_array(pdb_path)
            seqs, _ = struc.to_sequence(atom_array_complex)
            binder_seq, target_seq = str(seqs[0]), str(seqs[1])
            binder_seqs[pdb_id] = binder_seq
    return binder_seqs


def get_scheme_region_labels(seq, scheme: str = "imgt", chain: str = "H"):
    """ Given an input VHH seq extract list of seq length with indices indicating fmwk1-n & cdr1-n

        Parameters
        ----------
        seq : str
            Input sequence to be analyzed
        scheme : str
            Annotation scheme to be used. Default is IMGT (as specifed in PPIFlow paper)
        chain : str
            Chain ID to be analyzed. Default is H (Heavy) for VHH
    
        Returns
        -------
        scheme_region_labels : list
            List of length of seq with indices indicating fmwk1-n & cdr1-n
    """

    # 1. Create Annotator Object loaded with seqs, chain ID (H or L), and scheme
    annotator = SingleChainAnnotator(chains = [chain], # Specify chain with options for heavy: H & light: [L,K] 
                                     scheme = scheme) # Specify annotation scheme: imgt, aho, martin, or kabat

    # 2. Analyze seqs and determine if seqs are valid
    annotated_seqs = annotator.analyze_seq(seq)
    seq_numbered_list, percent_identity_list, chain_detect_list, error_list = annotated_seqs

    scheme_region_labels = annotator.assign_cdr_labels(numbering = seq_numbered_list, chain = chain, scheme = scheme)
    scheme_region_labels

    return scheme_region_labels


def extract_fwmk_indices(region_labels: list) -> str:
    """ Given an input list of scheme_region_labels, extract the indices of the fmwk regions

        Parameters
        ----------
        region_labels : list
            List of length of seq with indices indicating fmwk1-n & cdr1-n
    
        Returns
        -------
        fwmk_indices : str
            String of indices of fmwk regions
    """

    fwmk_indices = ' '.join([str(index + 1) for index, val in enumerate(region_labels) if "fmwk" in val])
    return fwmk_indices


def extract_cdr_indices(region_labels: list) -> str:
    """ Given an input list of scheme_region_labels, extract the indices of the cdr regions

        Parameters
        ----------
        region_labels : list
            List of length of seq with indices indicating fmwk1-n & cdr1-n
    
        Returns
        -------
        cdr_indices : str
            String of indices of cdr regions
    """

    cdr_indices = ','.join([f"A{(index + 1)}" for index, val in enumerate(region_labels) if "cdr" in val])
    return cdr_indices

def extract_fmwk_cdr_indices_from_folder(path_pdb_folder: str , output_csv_path: str = ""):
    """ Given an input path to a folder containing pdb files, 
            Extract the 1-indices of the FMWK regions (column: fw_index)
            Extract the 1-indices of the CDR regions and report as {chain_id}{cdr-index} (column: r2_cdr_pos)
            Save associated to pdb_input (column: pdb_name)

        Parameters
        ----------
        path_pdb_folder : str
            Path to folder containing pdb files
    
        Returns
        -------
        df_annotated_binders : pandas DataFrame
            DataFrame containing pdb_name, fw_index, r2_cdr_pos
    """
    binder_seqs = extract_binder_seqs(path_pdb_folder)
    annotated_binders = []
    for pdb_name, binder_seq in binder_seqs.items():
        scheme_region_labels = get_scheme_region_labels(binder_seq)
        fwmk_indices = extract_fwmk_indices(scheme_region_labels)
        cdr_indices = extract_cdr_indices(scheme_region_labels)
        annotated_binder = {'pdb_name' : pdb_name, 'fw_index' : fwmk_indices, 'r2_cdr_pos' : cdr_indices}
        annotated_binders.append(annotated_binder)
    df_annotated_binders = pd.DataFrame(annotated_binders)

    if output_csv_path != "":
        df_annotated_binders.to_csv(output_csv_path, index=False)

    return df_annotated_binders
